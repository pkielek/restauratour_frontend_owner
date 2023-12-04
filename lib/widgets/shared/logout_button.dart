import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';

import '../../model/auth.dart';

final logoutButtonHoverProvider = StateProvider<bool>((ref) => false);

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
        style: ButtonStyle(textStyle: MaterialStateProperty.all(inactiveNavigationButtonText), foregroundColor: MaterialStateProperty.all(primaryColor)),
        onPressed: () => ref.read(authProvider.notifier).logOut(),
        child: const Text.rich(TextSpan(children:[TextSpan(text: "Wyloguj się  "), WidgetSpan(child: Icon(Icons.logout))])));
  }
}
