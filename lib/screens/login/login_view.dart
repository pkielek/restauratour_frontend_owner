import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/providers/basic_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

part 'login_view.g.dart';

final emailProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<String>((ref) => "");
final errorMessageProvider = StateProvider<String>((ref) => "");
final showPasswordProvider = StateProvider<bool>((ref) => false);

@riverpod
Icon passwordVisibleIcon(ref) {
    return ref.watch(showPasswordProvider) == false
      ? const Icon(Icons.visibility_off)
      : const Icon(Icons.visibility);
}

@riverpod
Color passwordVisibleColor(ref) {
  return ref.watch(showPasswordProvider) == false ? primaryColor : Colors.black;
}

class LoginView extends ConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  void _login(RoundedLoadingButtonController controller, WidgetRef ref) async {
    if (ref.read(emailProvider.notifier).state.isValidEmail() &&
        ref.read(passwordProvider.notifier).state.length >= 4) {
      try {
        final formData = FormData.fromMap({
          'username': ref.read(emailProvider.notifier).state,
          'password': ref.read(passwordProvider.notifier).state
        });
        final response = await Dio()
            .post('http://127.0.0.1:8000/api/owners/login', data: formData);
        controller.success();
        ref.read(errorMessageProvider.notifier).state = "";
        ref.read(jwtTokenProvider.notifier).state =
            response.data["access_token"];
        ref.read(userNameProvider.notifier).state = response.data['name'];
      } on DioException catch (e) {
        controller.error();
        if (e.response != null) {
          Map responseBody = e.response!.data;
          ref.read(errorMessageProvider.notifier).state =
              responseBody['detail'];
        } else {
          ref.read(errorMessageProvider.notifier).state = "Coś poszło nie tak. Spróbuj zalogować się ponownie";
        }
      }
    } else {
      ref.read(errorMessageProvider.notifier).state =
          "Pola nie zostały wypełnione poprawnie";
      controller.error();
    }
    Timer(const Duration(seconds: 2), () {
      controller.reset();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Row(
      children: [
        Expanded(
            child: Image.asset(
          'images/logo.webp',
          semanticLabel: 'Restaura TOUR Logo',
          width: size.width * 0.5,
          height: size.height * 0.5,
        )),
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: size.width * 0.33,
                    height: size.height * 0.66,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                            child: SelectableText("Panel Administratora",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32))),
                        Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(children: [
                              TextFormField(
                                  validator: (input) {
                                    if (input == "") return null;
                                    return input!.isValidEmail()
                                        ? null
                                        : "Podaj prawidłowy adres e-mail";
                                  },
                                  onChanged: (value) => ref
                                      .read(emailProvider.notifier)
                                      .state = value,
                                  onFieldSubmitted: (_) =>
                                      _login(_submitController, ref),
                                  decoration: InputDecoration(
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.black,
                                    ),
                                    labelText: 'Adres e-mail',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(
                                            color: Colors.black)),
                                  )),
                              const SizedBox(height: 15),
                              TextFormField(
                                  validator: (value) =>
                                      value!.length < 4 && value.isNotEmpty
                                          ? "Hasło jest za krótkie"
                                          : null,
                                  onChanged: (value) => ref
                                      .read(passwordProvider.notifier)
                                      .state = value,
                                  onFieldSubmitted: (_) =>
                                      _login(_submitController, ref),
                                  obscureText: !ref.watch(showPasswordProvider),
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.key,
                                        color: Colors.black),
                                    labelText: 'Hasło',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    suffixIcon: IconButton(
                                      icon: ref
                                          .watch(passwordVisibleIconProvider),
                                      onPressed: () => ref
                                          .read(showPasswordProvider.notifier)
                                          .update((state) => !state),
                                      color: ref
                                          .watch(passwordVisibleColorProvider),
                                      splashRadius: 1.0,
                                    ),
                                  )),
                              const SizedBox(height: 15),
                              RoundedLoadingButton(
                                color: primaryColor,
                                successIcon: Icons.done,
                                failedIcon: Icons.close,
                                width: 2000,
                                child: Text('Zaloguj się!',
                                    style: TextStyle(color: Colors.white)),
                                controller: _submitController,
                                onPressed: () => _login(_submitController, ref),
                              ),
                              const SizedBox(height: 15),
                              SelectableText(ref.watch(errorMessageProvider),
                                  style: TextStyle(color: Colors.red)),
                            ])),
                        const Center(
                            child: SelectableText(
                                "Piotr Kiełek © 2023 | Wszelkie prawa zastrzeżone",
                                style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 12))),
                      ],
                    ))))
      ],
    ));
  }
}
