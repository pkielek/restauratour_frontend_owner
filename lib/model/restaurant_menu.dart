import 'dart:async';

import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'restaurant_menu.g.dart';
part 'restaurant_menu.freezed.dart';

enum RestaurantMenuItemType {
  @JsonValue("Nieaktywny")
  inactive,
  @JsonValue("Niedostępny")
  unavailable,
  @JsonValue("Dostępny")
  available;
}

@freezed
class RestaurantMenuItem with _$RestaurantMenuItem {
  RestaurantMenuItem._();
  factory RestaurantMenuItem({
    required int id,
    required String name,
    required String description,
    required double price,
    required int order,
    required RestaurantMenuItemType status,
    required String? photoUrl,
  }) = _RestaurantMenuItem;
  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuItemFromJson(json);

  static double? priceValidate(String value) {
    return RegExp(r'^([1-9][0-9]{0,3}[.,][0-9]{2}|0[,.][1-9][0-9])$').hasMatch(value) ? double.parse(value.replaceAll(',','.')) : null;
  }
  
  bool get isValid {
    if(name.length<3) return false;
    return true;
  }
}

@freezed
class RestaurantMenuCategory with _$RestaurantMenuCategory {
  factory RestaurantMenuCategory(
      {required int id,
      required String name,
      required bool isVisible,
      required int order,
      required List<RestaurantMenuItem> items,
      @JsonKey(ignore: true) @Default(false) bool restartTimer,
      @JsonKey(ignore: true) @Default(false) bool isPending,
      @JsonKey(ignore: true) Timer? timer,
      @JsonKey(ignore: true) Timer? updateTimer}) = _RestaurantMenuCategory;
  factory RestaurantMenuCategory.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuCategoryFromJson(json);
}

@freezed
class RestaurantMenuInfo with _$RestaurantMenuInfo {
  factory RestaurantMenuInfo(
          {required List<RestaurantMenuCategory> menu,
          @JsonKey(ignore: true) @Default(0) int selectedCategory,
          @JsonKey(ignore: true) RestaurantMenuItem? editedItem}) =
      _RestaurantMenuInfo;
  factory RestaurantMenuInfo.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuInfoFromJson(json);
}

@riverpod
class RestaurantMenu extends _$RestaurantMenu {
  @override
  Future<RestaurantMenuInfo> build([int? restaurantId]) async {
    if (ref.read(authProvider).value!.authType == AuthType.user &&
        restaurantId == null) {
      throw ArgumentError();
    }
    final token = ref.read(authProvider).value!;
    try {
      final response = await Dio().get(
          '${dotenv.env['${ref.read(authProvider).value!.authType.name.toUpperCase()}_API_URL']!}restaurant-menu',
          data: restaurantId != null
              ? FormData.fromMap({"restaurant_id": restaurantId})
              : null,
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      final menu = (response.data as List<dynamic>)
          .map((e) => RestaurantMenuCategory.fromJson(e))
          .toList();
      return RestaurantMenuInfo(
          menu: menu, selectedCategory: menu.isNotEmpty ? menu[0].id : 0);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później lub odśwież stronę";
      }
    }
  }

  Future<void> selectCategory(int id) async {
    final currentCategory = state.value!.menu
        .firstWhere((element) => element.id == state.value!.selectedCategory);
    if (currentCategory.timer != null &&
        currentCategory.timer!.isActive &&
        currentCategory.name.length >= 4) {
      currentCategory.timer!.cancel();
      currentCategory.updateTimer!.cancel();
      await saveCategoryName(currentCategory.id);
    }
    state = AsyncData(state.value!.copyWith(selectedCategory: id));
  }

  Future<bool> menuUpdateAction(
      Map<String, dynamic> data, String pathName) async {
    final token = ref.read(authProvider).value!;
    try {
      data.putIfAbsent("restaurant_id", () => restaurantId);
      final response = await Dio().post(
          '${dotenv.env['${ref.read(authProvider).value!.authType.name.toUpperCase()}_API_URL']!}$pathName',
          data: data,
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      final menu = (response.data as List<dynamic>)
          .map((e) => RestaurantMenuCategory.fromJson(e))
          .toList();
      state = AsyncData(state.value!.copyWith(
          menu: menu,
          selectedCategory: menu.isEmpty
              ? 0
              : (state.value!.selectedCategory == 0
                  ? menu[0].id
                  : state.value!.selectedCategory)));
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak, spróbuj ponownie później lub odśwież stronę",
            true);
      }
      return false;
    }
  }

  Future<void> addCategory() async {
    await menuUpdateAction({}, "add-category");
  }

  Future<void> deleteCategory(int id) async {
    if (state.value!.selectedCategory == id) {
      state = AsyncData(state.value!.copyWith(
          selectedCategory:
              state.value!.menu.every((element) => element.id == id)
                  ? 0
                  : state.value!.menu
                      .firstWhere((element) => element.id != id)
                      .id));
    }
    await menuUpdateAction({"category_id": id}, "delete-category");
  }

  Future<void> switchVisibility(int id) async {
    await menuUpdateAction({"category_id": id}, "switch-category-visibility");
  }

  void updateCategoryName(int id, String value) {
    state.value!.menu.firstWhere((element) => element.id == id).timer?.cancel();
    state.value!.menu
        .firstWhere((element) => element.id == id)
        .updateTimer
        ?.cancel();
    state = AsyncData(state.value!.copyWith(menu: [
      for (final category in state.value!.menu)
        if (category.id == id)
          category.copyWith(
              restartTimer: false,
              updateTimer: Timer(const Duration(milliseconds: 50), () {
                if (value.length >= 4 &&
                    !state.value!.menu
                        .any((element) => element.name == value)) {
                  state = AsyncData(state.value!.copyWith(menu: [
                    for (final category in state.value!.menu)
                      if (category.id == id)
                        category.copyWith(
                            name: value,
                            timer: Timer(const Duration(seconds: 3),
                                () => saveCategoryName(id)),
                            updateTimer: null,
                            restartTimer: true)
                      else
                        category
                  ]));
                } else {
                  state = AsyncData(state.value!.copyWith(menu: [
                    for (final category in state.value!.menu)
                      if (category.id == id)
                        category.copyWith(
                            name: value, timer: null, updateTimer: null)
                      else
                        category
                  ]));
                }
              }))
        else
          category
    ]));
  }

  Future<void> saveCategoryName(int id) async {
    final newName =
        state.value!.menu.firstWhere((element) => element.id == id).name;
    final success = await menuUpdateAction(
        {"category_id": id, "new_value": newName}, "update-category-name");
    if (success) {
      fluttertoastDefault("Nazwa Kategorii - $newName - zapisana poprawnie");
    }
  }

  Future<void> categoryReorder(int oldIndex, int newIndex) async {
    if (newIndex > state.value!.menu.length) {
      newIndex = state.value!.menu.length;
    }
    if (oldIndex < newIndex) newIndex--;
    state = AsyncData(state.value!.copyWith(menu: [
      for (final (i, category) in state.value!.menu.indexed)
        if (i == oldIndex)
          state.value!.menu[newIndex].copyWith(isPending: true)
        else if (i == newIndex)
          state.value!.menu[oldIndex].copyWith(isPending: true)
        else
          category
    ]));
    await menuUpdateAction({
      "category_id_1": state.value!.menu[oldIndex].id,
      "category_id_2": state.value!.menu[newIndex].id,
    }, "swap-categories-orders");
  }

  void setEditedItem(RestaurantMenuItem item) {
    state = AsyncData(state.value!.copyWith(editedItem: item));
  }

  void updateEditedItemName(String? value) {
    if(value != null && value.length>3) {
      state = AsyncData(state.value!.copyWith.editedItem!(name: value));
    }
  }

  void updateEditedItemDescription(String? value) {
    state = AsyncData(state.value!.copyWith.editedItem!(name: value ?? ""));
  }

  void updateEditedItemPrice(String? value) {

    if(value != null && RestaurantMenuItem.priceValidate(value) != null) {
      state = AsyncData(state.value!.copyWith.editedItem!(price:  RestaurantMenuItem.priceValidate(value)!));
    }
  }
}
