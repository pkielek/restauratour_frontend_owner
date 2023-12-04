import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/widgets/login/email_field.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../model/auth.dart';
import '../../widgets/helper/styles.dart';
import '../../widgets/login/password_field.dart';

final errorMessageProvider = StateProvider<String>((ref) => "");

class LoginView extends ConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  void _login(RoundedLoadingButtonController controller, WidgetRef ref) async {
    ref.read(errorMessageProvider.notifier).state = "";
    if (ref.read(emailProvider.notifier).state.isValidEmail() &&
        ref.read(passwordProvider.notifier).state.length >= 4) {
      try {
        final formData = FormData.fromMap({
          'username': ref.read(emailProvider.notifier).state,
          'password': ref.read(passwordProvider.notifier).state
        });
        final response = await Dio()
            .post('${dotenv.env['API_URL']!}login', data: formData);
        controller.success();
        ref.read(errorMessageProvider.notifier).state = "";
        ref.read(authProvider.notifier).login(response.data["access_token"]);
      } on DioException catch (e) {
        controller.error();
        if (e.response != null) {
          Map responseBody = e.response!.data;
          ref.read(errorMessageProvider.notifier).state =
              responseBody['detail'];
        } else {
          ref.read(errorMessageProvider.notifier).state =
              "Coś poszło nie tak. Spróbuj zalogować się ponownie";
        }
      }
    } else {
      ref.read(errorMessageProvider.notifier).state =
          "Pola nie zostały wypełnione poprawnie";
      controller.error();
    }
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
                                style: boldBig)),
                        Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(children: [
                              EmailField(
                                  onSubmit: () =>
                                      _login(_submitController, ref)),
                              const SizedBox(height: 15),
                              PasswordField(onSubmit: () {
                                _login(_submitController, ref);
                              }),
                              const SizedBox(height: 15),
                              RoundedLoadingButton(
                                color: primaryColor,
                                successIcon: Icons.done,
                                failedIcon: Icons.close,
                                resetAfterDuration: true,
                                resetDuration: const Duration(seconds: 2),
                                width: 2000,
                                controller: _submitController,
                                onPressed: () => _login(_submitController, ref),
                                child: const Text('Zaloguj się!',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(height: 15),
                              SelectableText(ref.watch(errorMessageProvider),
                                  style: const TextStyle(color: Colors.red)),
                            ])),
                        const Center(
                            child: SelectableText(
                                "Piotr Kiełek © 2023 | Wszelkie prawa zastrzeżone",
                                style: footprintStyle)),
                      ],
                    ))))
      ],
    ));
  }
}
