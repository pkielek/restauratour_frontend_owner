import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/login.dart';
import 'package:restaurant_helper/widgets/login/email_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:utils/utils.dart';

import '../../widgets/login/password_field.dart';

class LoginView extends ConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  LoginView({super.key});

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
                                  onSubmit:
                                      ref.read(loginProvider.notifier).login),
                              const SizedBox(height: 15),
                              PasswordField(
                                  onSubmit:
                                      ref.read(loginProvider.notifier).login),
                              const SizedBox(height: 15),
                              RoundedLoadingButton(
                                color: primaryColor,
                                successIcon: Icons.done,
                                failedIcon: Icons.close,
                                resetAfterDuration: true,
                                resetDuration: const Duration(seconds: 2),
                                width: 2000,
                                controller: _submitController,
                                onPressed:
                                    ref.read(loginProvider.notifier).login,
                                child: const Text('Zaloguj się!',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(height: 15),
                              SelectableText(
                                  ref.watch(loginProvider).when(
                                      data: (data) => data.errorMessage,
                                      error: (_, __) => "Niespodziewany błąd",
                                      loading: () => ""),
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
