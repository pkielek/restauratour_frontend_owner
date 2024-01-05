import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../constants.dart';

part 'password_field.g.dart';

final showPasswordProvider = StateProvider<bool>((ref) => false);
final passwordProvider = StateProvider<String>((ref) => "");

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

class PasswordField extends ConsumerWidget {
  const PasswordField({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
        validator: (value) => value!.length < 4 && value.isNotEmpty
            ? "Hasło jest za krótkie"
            : null,
        onChanged: (value) => ref.read(passwordProvider.notifier).state = value,
        onFieldSubmitted: (_) => onSubmit(),
        obscureText: !ref.watch(showPasswordProvider),
        decoration: InputDecoration(
          icon: const Icon(Icons.key, color: Colors.black),
          labelText: 'Hasło',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          suffixIcon: IconButton(
            icon: ref.watch(passwordVisibleIconProvider),
            onPressed: () => ref
                .read(showPasswordProvider.notifier)
                .update((state) => !state),
            color: ref.watch(passwordVisibleColorProvider),
            splashRadius: 1.0,
          ),
        ));
  }
}
