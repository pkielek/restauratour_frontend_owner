import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'restaurant_info.g.dart';
part 'restaurant_info.freezed.dart';

@freezed
class RestaurantFlag with _$RestaurantFlag {
  factory RestaurantFlag(
      {required int id,
      required String name,
      required bool setting,
      @Default("") String? description}) = _RestaurantFlag;

  factory RestaurantFlag.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFlagFromJson(json);
}

@freezed
class RestaurantHour with _$RestaurantHour {
  RestaurantHour._();
  factory RestaurantHour({
    required String openTime,
    required String closeTime,
    required bool temporary,
    required bool closed,
  }) = _RestaurantHour;

  factory RestaurantHour.fromJson(Map<String, dynamic> json) =>
      _$RestaurantHourFromJson(json);

  bool isValidTime(String time) =>
      RegExp(r'^(:?[01][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time);

  String? timeValidator(String? time) {
    if (time == null || time == "") return null;
    if (!isValidTime(time)) {
      return "Format HH:MM";
    }
    return null;
  }

  String? openTimeValidator(String? time) {
    return timeValidator(time) ??
        (isValidTime(closeTime)
            ? (time!.compareTo(closeTime) >= 0 ? "Od < do" : null)
            : null);
  }

  String? closeTimeValidator(String? time) {
    return timeValidator(time) ??
        (isValidTime(openTime)
            ? (time!.compareTo(openTime) <= 0 ? "Do > od" : null)
            : null);
  }
}

@freezed
class RestaurantInfo with _$RestaurantInfo {
  RestaurantInfo._();
  factory RestaurantInfo(
      {@JsonKey(includeToJson: false) required String name,
      @JsonKey(includeToJson: false) required String nip,
      @JsonKey(includeToJson: false) required String country,
      @JsonKey(includeToJson: false) required String streetNumber,
      @JsonKey(includeToJson: false) required String city,
      @JsonKey(includeToJson: false) required String postalCode,
      @JsonKey(includeFromJson: false, includeToJson: false)
      @Default(false)
      isChanged,
      @JsonKey(includeFromJson: false, includeToJson: false)
      @Default("")
      String newPassword,
      @JsonKey(includeFromJson: false, includeToJson: false)
      @Default("")
      String confirmNewPassword,
      required String email,
      required String phoneNumber,
      required List<RestaurantFlag> flags,
      required Map<int, RestaurantHour> openingHours}) = _RestaurantInfo;
  factory RestaurantInfo.fromJson(Map<String, dynamic> json) =>
      _$RestaurantInfoFromJson(json);

  String get toFullAddress => "$streetNumber, $postalCode $city, $country";

  bool get areNewPasswordsIdentical => newPassword == confirmNewPassword;
}

@riverpod
class Info extends _$Info {
  @override
  Future<RestaurantInfo> build([int? restaurantId]) async {
    if (ref.read(authProvider).value!.authType == AuthType.user &&
        restaurantId == null) {
      throw ArgumentError();
    }
    final token = ref.read(authProvider).value!;
    try {
      final response = await Dio().get(
          '${dotenv.env['${ref.read(authProvider).value!.authType.name.toUpperCase()}_API_URL']!}restaurant-info',
          data: restaurantId != null
              ? FormData.fromMap({"restaurant_id": restaurantId})
              : null,
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      return RestaurantInfo.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później lub odśwież stronę";
      }
    }
  }

  void updateEmail(String email) {
    state = AsyncData(state.value!.copyWith(email: email, isChanged: true));
  }

  void updatePhoneNumber(PhoneNumber phoneNumber) {
    state = AsyncData(state.value!
        .copyWith(phoneNumber: phoneNumber.completeNumber, isChanged: true));
  }

  void toggleCheckbox(int id) {
    state = AsyncData(state.value!.copyWith(isChanged: true, flags: [
      for (final flag in state.value!.flags)
        if (flag.id == id) flag.copyWith(setting: !flag.setting) else flag
    ]));
  }

  void updateOpenTime(int day, String? time) {
    if (time == null ||
        state.value!.openingHours[day]!.openTimeValidator(time) != null) return;
    state = AsyncData(state.value!.copyWith(isChanged: true, openingHours: {
      for (final value in state.value!.openingHours.entries.toList())
        if (value.key == day)
          value.key: value.value.copyWith(
              openTime: time,
              closed: time.isEmpty && value.value.closeTime.isEmpty)
        else
          value.key: value.value
    }));
  }

  void updateCloseTime(int day, String? time) {
    if (time == null ||
        state.value!.openingHours[day]!.closeTimeValidator(time) != null)
      return;
    state = AsyncData(state.value!.copyWith(isChanged: true, openingHours: {
      for (final value in state.value!.openingHours.entries.toList())
        if (value.key == day)
          value.key: value.value.copyWith(
              closeTime: time,
              closed: time.isEmpty && value.value.openTime.isEmpty)
        else
          value.key: value.value
    }));
  }

  void toggleClosed(int day) {
    state = AsyncData(state.value!.copyWith(isChanged: true, openingHours: {
      for (final value in state.value!.openingHours.entries.toList())
        if (value.key == day)
          value.key: value.value.copyWith(
              closeTime: "", openTime: "", closed: !value.value.closed)
        else
          value.key: value.value
    }));
  }

  void toggleTemporary(int day) {
    state = AsyncData(state.value!.copyWith(isChanged: true, openingHours: {
      for (final value in state.value!.openingHours.entries.toList())
        if (value.key == day)
          value.key: value.value.copyWith(temporary: !value.value.temporary)
        else
          value.key: value.value
    }));
  }

  void updateNewPassword(String? input) {
    if (input == null) return;
    state = AsyncData(state.value!.copyWith(newPassword: input));
  }

  void updateConfirmNewPassword(String? input) {
    if (input == null) return;
    state = AsyncData(state.value!.copyWith(confirmNewPassword: input));
  }

  void cancelPasswordUpdate() {
    state = AsyncData(
        state.value!.copyWith(newPassword: "", confirmNewPassword: ""));
  }

  Future<bool> saveNewPassword() async {
    if (validatePassword(state.value!.newPassword).isNotEmpty ||
        state.value!.confirmNewPassword != state.value!.newPassword) {
      fluttertoastDefault(
          "Nowe hasło nie spełnia wymagań - odnieś się do błędów pod polami",
          true);
      return false;
    }
    try {
      final token = ref.read(authProvider).value!;
      await Dio().post('${dotenv.env['OWNER_API_URL']!}update-password',
          data: {
            "new_password": state.value!.newPassword,
            "confirm_password": state.value!.confirmNewPassword
          },
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      fluttertoastDefault("Dane zapisano poprawnie!");
      cancelPasswordUpdate();
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj jeszcze raz ponownie", true);
      }
      return false;
    }
  }

  void saveData() async {
    try {
      final token = ref.read(authProvider).value!;
      await Dio().post('${dotenv.env['OWNER_API_URL']!}save-restaurant-info',
          data: state.value!.toJson(),
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      fluttertoastDefault("Dane zapisano poprawnie!");
      state = AsyncData(state.value!.copyWith(isChanged: false));
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
}

@riverpod
Future<GoogleGeocodingResponse> restaurantMap(RestaurantMapRef ref,
    [int? restaurantId]) async {
  final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
  return await ref.read(InfoProvider(restaurantId)).whenData((value) async {
    return await GoogleGeocodingApi(googleApiKey).search(value.toFullAddress,
        language: 'pl', region: 'pl', bounds: '54.83,24.15|49.00,14.12');
  }).value!;
}
