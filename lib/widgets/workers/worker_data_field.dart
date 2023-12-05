import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/create_worker.dart';

class WorkerDataField extends ConsumerWidget {
  const WorkerDataField(
      {super.key,
      required this.onSubmit,
      required this.fieldName,
      required this.fieldShownName,
      required this.controller});

  final String fieldName;
  final String fieldShownName;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
        controller:controller,
        onChanged: (value) => ref
            .read(createWorkerStateProvider.notifier)
            .updateField(fieldName, value),
        onFieldSubmitted: (_) => onSubmit,
        decoration: InputDecoration(
          icon: const Icon(
            Icons.person,
            color: Colors.black,
          ),
          labelText: fieldShownName,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ));
  }
}
