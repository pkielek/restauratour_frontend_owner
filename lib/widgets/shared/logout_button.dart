import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';


class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
        style: ButtonStyle(textStyle: MaterialStateProperty.all(inactiveNavigationButtonText), foregroundColor: MaterialStateProperty.all(primaryColor)),
        onPressed: ref.read(authProvider.notifier).logOut,
        child: const Text.rich(TextSpan(children:[TextSpan(text: "Wyloguj się  "), WidgetSpan(child: Icon(Icons.logout))])));
  }
}
