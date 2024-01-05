import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/constants.dart';

final emailProvider = StateProvider<String>((ref) => "");

class EmailField extends ConsumerWidget {
  const EmailField({super.key, required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return TextFormField(
        validator: (input) {
          if (input == "") return null;
          return input!.isValidEmail() ? null : "Podaj prawidłowy adres e-mail";
        },
        onChanged: (value) => ref.read(emailProvider.notifier).state = value,
        onFieldSubmitted: (_) => onSubmit(),
        decoration: InputDecoration(
          icon: const Icon(
            Icons.person,
            color: Colors.black,
          ),
          labelText: 'Adres e-mail',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ));
  }
}
