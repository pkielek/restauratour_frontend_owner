import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

import 'auth.dart';

part 'login.freezed.dart';
part 'login.g.dart';

@freezed
class LoginData with _$LoginData {
  LoginData._();

  factory LoginData({
    @Default("") String email,
    @Default("") String password,
    @Default(false) bool showPassword,
    @Default("") String errorMessage,
  }) = _LoginData;

  Icon get passwordVisibleIcon => showPassword
      ? const Icon(Icons.visibility)
      : const Icon(Icons.visibility_off);
  Color get passwordVisibleColor => showPassword ? Colors.black : primaryColor;
}

@riverpod
class Login extends _$Login {
  @override
  Future<LoginData> build() async {
    return LoginData();
  }

  void updateEmail(String email) {
    state = AsyncData(state.value!.copyWith(email: email));
  }

  void updatePassword(String password) {
    state = AsyncData(state.value!.copyWith(password: password));
  }

  void toggleShowPassword() {
    state = AsyncData(
        state.value!.copyWith(showPassword: !state.value!.showPassword));
  }

  void login() async {
    state = AsyncData(state.value!.copyWith(errorMessage: ""));
    if (state.value!.email.isValidEmail() &&
        state.value!.password.length >= 4) {
      try {
        final formData = FormData.fromMap({
          'username': state.value!.email,
          'password': state.value!.password
        });
        final response =
            await Dio().post('${dotenv.env['OWNER_API_URL']!}login', data: formData);
        state = AsyncData(state.value!.copyWith(errorMessage: ""));
        ref.read(authProvider.notifier).login(response.data["access_token"]);
      } on DioException catch (e) {
        if (e.response != null) {
          Map responseBody = e.response!.data;
          state = AsyncData(
              state.value!.copyWith(errorMessage: responseBody['detail']));
        } else {
          state = AsyncData(state.value!.copyWith(
              errorMessage:
                  "Coś poszło nie tak. Spróbuj zalogować się ponownie"));
        }
      }
    } else {
      state = AsyncData(state.value!
          .copyWith(errorMessage: "Pola nie zostały wypełnione poprawnie"));
    }
  }
}
