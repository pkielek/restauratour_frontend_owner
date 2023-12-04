import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/model/create_worker.dart';

class WorkerEmailField extends ConsumerWidget {
  const WorkerEmailField({super.key, required VoidCallback this.onSubmit, required TextEditingController this.controller});

  final VoidCallback onSubmit;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
        controller: controller,
        validator: (input) {
          if (input == "") return null;
          return input!.isValidEmail() ? null : "Podaj prawidłowy adres e-mail";
        },
        onChanged: (value) => ref.read(createWorkerStateProvider.notifier).updateEmail(value),
        onFieldSubmitted: (_) => onSubmit,
        decoration: InputDecoration(
          icon: const Icon(
            Icons.email,
            color: Colors.black,
          ),
          labelText: 'Adres e-mail',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ));
  }
}
