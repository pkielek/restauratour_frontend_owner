import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';

class EmailField extends ConsumerWidget {
  const EmailField(
      {super.key,
      required this.onChanged,
      this.onSubmit,
      this.controller,
      this.initialValue,
      this.labelText});

  final Function(String) onChanged;
  final VoidCallback? onSubmit;
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: initialValue,
        controller: controller,
        validator: (input) {
          if (input == "") return null;
          return input!.isValidEmail() ? null : "Podaj prawidłowy adres e-mail";
        },
        onChanged: onChanged,
        onFieldSubmitted: (_) => onSubmit,
        decoration: defaultDecoration(
            icon: Icons.person, labelText: labelText ?? 'Adres e-mail'));
  }
}
