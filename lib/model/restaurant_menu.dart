import 'dart:async';
import 'dart:typed_data';

import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'restaurant_menu.g.dart';
part 'restaurant_menu.freezed.dart';

enum RestaurantMenuItemType {
  @JsonValue("Dostępny")
  available,
  @JsonValue("Nieaktywny")
  inactive,
  @JsonValue("Niedostępny")
  unavailable;

  String get label {
    switch (this) {
      case inactive:
        return "Nieaktywny";
      case unavailable:
        return "Niedostępny";
      case available:
        return "Dostępny";
    }
  }

  Icon get icon {
    switch (this) {
      case inactive:
        return const Icon(Icons.close, color: Colors.grey);
      case unavailable:
        return const Icon(Icons.block, color: primaryColor);
      case available:
        return const Icon(Icons.done, color: Colors.green);
    }
  }
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
    required String photoUrl,
    @JsonKey(ignore: true) @Default(false) bool isPending,
  }) = _RestaurantMenuItem;
  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuItemFromJson(json);

  static double? priceValidate(String value) {
    return RegExp(r'^(:?[1-9][0-9]{0,3}[.,][0-9]{2}|0[,.][1-9][0-9])$')
            .hasMatch(value)
        ? double.parse(value.replaceAll(',', '.'))
        : null;
  }

  bool get isValid {
    if (name.length < 3) return false;
    if (price < 0.10 || price > 9999.99) return false;
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
          required String photoUrl,
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
      Map responseBody = response.data;
      final menu = (responseBody['menu'] as List<dynamic>)
          .map((e) => RestaurantMenuCategory.fromJson(e))
          .toList();
      return RestaurantMenuInfo(
          menu: menu,
          selectedCategory: menu.isNotEmpty ? menu[0].id : 0,
          photoUrl: responseBody['photo_url'],
          editedItem: RestaurantMenuItem(
              id: -1,
              name: "",
              description: "",
              price: 0.00,
              order: -1,
              status: RestaurantMenuItemType.inactive,
              photoUrl: ""));
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później lub odśwież stronę";
      }
    }
  }

  Future<bool> uploadRestaurantImage(Uint8List bytes) async {
    if(restaurantId != null) return false;
    try {
      final token = ref.read(authProvider).value!;
      final formData = FormData.fromMap(
          {"file": MultipartFile.fromBytes(bytes, filename: "file.png")});
      final url = await Dio().post(
          '${dotenv.env['OWNER_API_URL']!}upload-restaurant-photo',
          data: formData,
          options: Options(
              headers: {"Authorization": "Bearer ${token.jwtToken}"},
              contentType: 'multipart/form-data'));
      fluttertoastDefault("Zdjęcie zapisano!");
      state = AsyncData(state.value!.copyWith(photoUrl: url.data));
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj zapisać dane ponownie później", true);
      }
      return false;
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
    if(restaurantId != null) false;
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
    if(restaurantId != null) return;
    await menuUpdateAction({}, "add-category");
  }

  Future<void> deleteCategory(int id) async {
    if(restaurantId != null) return;
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
    if(restaurantId != null) return;
    await menuUpdateAction({"category_id": id}, "switch-category-visibility");
  }

  void updateCategoryName(int id, String value) {
    if(restaurantId != null) return;
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
    if(restaurantId != null) return;
    final newName =
        state.value!.menu.firstWhere((element) => element.id == id).name;
    final success = await menuUpdateAction(
        {"category_id": id, "new_value": newName}, "update-category-name");
    if (success) {
      fluttertoastDefault("Nazwa Kategorii - $newName - zapisana poprawnie");
    }
  }

  Future<void> categoryReorder(int oldIndex, int newIndex) async {
    if(restaurantId != null) return;
    if (newIndex > state.value!.menu.length) {
      newIndex = state.value!.menu.length;
    }
    if (oldIndex < newIndex) newIndex--;
    if (oldIndex == newIndex) return;
    final item1 = state.value!.menu[oldIndex];
    final item2 = state.value!.menu[newIndex];
    state = AsyncData(state.value!.copyWith(menu: [
      for (final (i, category) in state.value!.menu.indexed)
        if(i == newIndex)
          if(newIndex > oldIndex)
            ...[category,item1.copyWith(isPending: true)]
          else
            ...[item1.copyWith(isPending: true),category]
        else if(i != oldIndex)
          category
    ]));
    await menuUpdateAction({
      "category_id_1": item1.id,
      "category_id_2": item2.id,
    }, "swap-categories-orders");
  }

  Future<void> itemReorder(int oldIndex, int newIndex) async {
    if(restaurantId != null) return;
    if(oldIndex == newIndex) return;
    final selectedCategory = state.value!.menu.firstWhere((element) => element.id==state.value!.selectedCategory);

    final item1 = selectedCategory.items[oldIndex];
    final item2 = selectedCategory.items[newIndex];
    state = AsyncData(state.value!.copyWith(menu: [
      for (final category in state.value!.menu)
        if (category.id == selectedCategory.id)
          category.copyWith(items:[
            for (final (i,item) in category.items.indexed)
              if (i == newIndex)
                if(newIndex > oldIndex)
                  ...[item,category.items[oldIndex].copyWith(isPending: true)]
                else
                  ...[category.items[oldIndex].copyWith(isPending: true),item]
              else if(i != oldIndex)
                item
          ])
        else
          category
    ]));
    await menuUpdateAction({
      "item_id_1": item1.id,
      "item_id_2": item2.id,
      "category_id": selectedCategory.id
    }, "swap-items-orders");
  }

  void setEditedItem(RestaurantMenuItem item) {
    if(restaurantId != null) return;
    state = AsyncData(state.value!.copyWith(editedItem: item));
  }

  void updateEditedItemName(String? value) {
    if(restaurantId != null) return;
    if (value != null && value.length > 3) {
      state = AsyncData(state.value!.copyWith.editedItem!(name: value));
    }
  }

  void updateEditedItemDescription(String? value) {
    if(restaurantId != null) return;
    state =
        AsyncData(state.value!.copyWith.editedItem!(description: value ?? ""));
  }

  void updateEditedItemPrice(String? value) {
    if(restaurantId != null) return;
    if (value != null && RestaurantMenuItem.priceValidate(value) != null) {
      state = AsyncData(state.value!.copyWith.editedItem!(
          price: RestaurantMenuItem.priceValidate(value)!));
    }
  }

  void updateEditedItemStatus(RestaurantMenuItemType? value) {
    if(restaurantId != null) return;
    if (value == null) return;
    state = AsyncData(state.value!.copyWith.editedItem!(status: value));
  }

  Future<bool> uploadEditedItemPhoto(Uint8List bytes) async {
    if(restaurantId != null) return false;
    try {
      final token = ref.read(authProvider).value!;
      final formData = FormData.fromMap(
          {"file": MultipartFile.fromBytes(bytes, filename: "file.png")});
      final url = await Dio().post(
          '${dotenv.env['OWNER_API_URL']!}upload-item-photo',
          data: formData,
          options: Options(
              headers: {"Authorization": "Bearer ${token.jwtToken}"},
              contentType: 'multipart/form-data'));
      fluttertoastDefault("Zdjęcie zapisano!");
      state = AsyncData(state.value!.copyWith.editedItem!(photoUrl: url.data));
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj zapisać dane ponownie później", true);
      }
      return false;
    }
  }

  Future<bool> saveEditedItem() async {
    if(restaurantId != null) return false;
    final prevData = state.value!.editedItem!;
    try {
      final token = ref.read(authProvider).value!;
      state = AsyncData(state.value!.copyWith.editedItem!(id:-2));
      final data = await Dio().post(
          '${dotenv.env['OWNER_API_URL']!}update-item',
          data: {"item": prevData.toJson(), "category_id": state.value!.selectedCategory},
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      fluttertoastDefault("Zapisano zmiany pozycji!");
      final newMenu = (data.data as List<dynamic>)
          .map((e) => RestaurantMenuCategory.fromJson(e))
          .toList();
      state = AsyncData(state.value!.copyWith(
          menu: newMenu,
          editedItem: RestaurantMenuItem(
              id: -1,
              name: "",
              description: "",
              price: 0.00,
              order: -1,
              status: RestaurantMenuItemType.inactive,
              photoUrl: "")));
      return true;
    } on DioException catch (e) {
      state = AsyncData(state.value!.copyWith.editedItem!(id:prevData.id));
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj zapisać dane ponownie później", true);
      }
      return false;
    }
  }

  void setEmptyEditedItemPhoto() {
    if(restaurantId != null) return;
    state = AsyncData(state.value!.copyWith.editedItem!(photoUrl: ""));
  }

  void removeEditedItemPhoto() async {
    if(restaurantId != null) return;
    try {
      final token = ref.read(authProvider).value!;
      await Dio().post('${dotenv.env['OWNER_API_URL']!}delete-uploade-photo',
          data: {
            "url": state.value!.editedItem!.photoUrl,
          },
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      state = AsyncData(state.value!.copyWith.editedItem!(photoUrl: ""));
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj zapisać dane ponownie później", true);
      }
    }
  }
  Future<bool> deleteItem(int id) async {
    if(restaurantId != null) return false;
    state = AsyncData(state.value!.copyWith.editedItem!(isPending: true));
    return await menuUpdateAction({"item_id": id}, "delete-item");
  }
}
