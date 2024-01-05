import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/login.dart';


class PasswordField extends ConsumerWidget {
  const PasswordField({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
        validator: (value) => value!.length < 4 && value.isNotEmpty
            ? "Hasło jest za krótkie"
            : null,
        onChanged: ref.read(loginProvider.notifier).updatePassword,
        onFieldSubmitted: (_) => onSubmit(),
        obscureText: !(ref.watch(loginProvider).value?.showPassword ?? true),
        decoration: InputDecoration(
          icon: const Icon(Icons.key, color: Colors.black),
          labelText: 'Hasło',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          suffixIcon: IconButton(
            icon: ref.watch(loginProvider).value?.passwordVisibleIcon ?? const Icon(Icons.visibility),
            onPressed: ref.read(loginProvider.notifier).toggleShowPassword,
            color: ref.watch(loginProvider).value?.passwordVisibleColor ?? Colors.black,
            splashRadius: 1.0,
          ),
        ));
  }
}
