import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper/model/worker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';


part 'create_worker.freezed.dart';
part 'create_worker.g.dart';

@freezed
class CreateWorker with _$CreateWorker {
  factory CreateWorker({
    @Default("")
    String firstName,
    @Default("")
    String surname,
    @Default("")
    String email,
    @Default({})
    @JsonKey(ignore: true)
    Map<String,TextEditingController> controllers,
  }) = _CreateWorker;

  factory CreateWorker.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkerFromJson(json);
}

@riverpod
class CreateWorkerState extends _$CreateWorkerState {
  @override
  CreateWorker build() {
    state = CreateWorker();
    return state;
  }

  void updateControllers(Map<String,TextEditingController> controllers) {
    state = state.copyWith(controllers: controllers);
  }

  void resetForm() {
    state = state.copyWith(email:"",firstName:"",surname:"");
    state.controllers.forEach((key, value) {value.clear();});
  }

  void updateField(String fieldName, String value) {
    if (fieldName == 'email') {
      updateEmail(value);
    } else if (fieldName == 'firstName') {
      updateFirstName(value);
    } else if (fieldName == 'surname') {
      updateSurname(value);
    } else {
      fluttertoastDefault("Błąd aplikacji", true);
    }
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName);
  }

  void updateSurname(String surname) {
    state = state.copyWith(surname: surname);
  }

  void sendForm(RoundedLoadingButtonController controller) async {
    if (state.email.isValidEmail()) {
      try {
        final token = ref.read(authProvider).value!;
        final formData = state.toJson();
        final response = await Dio().post(
            '${dotenv.env['OWNER_API_URL']!}create-worker',
            data: formData,
            options: Options(
                headers: {"Authorization": "Bearer ${token.jwtToken}"}));
        controller.reset();
        resetForm();
        fluttertoastDefault(response.data['message']);
        ref.read(workerListProvider.notifier).refresh();
      } on DioException catch (e) {
        controller.error();
        if (e.response != null) {
          Map responseBody = e.response!.data;
          fluttertoastDefault(responseBody['detail'], true);
        } else {
          fluttertoastDefault(
              "Coś poszło nie tak. Spróbuj ponownie później", true);
        }
      }
    } else {
      fluttertoastDefault("Pola nie zostały wypełnione poprawnie", true);
      controller.error();
    }
  }
}
