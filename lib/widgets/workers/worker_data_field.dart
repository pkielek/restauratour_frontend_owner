import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/create_worker.dart';
import 'package:utils/utils.dart';

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
        decoration: defaultDecoration(icon:Icons.person,labelText:fieldShownName),
        );
  }
}
