import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';

class PlannerPanelButton extends ConsumerWidget {
  const PlannerPanelButton(
      {super.key,
      required this.callback,
      required this.text,
      this.color = Colors.white,
      this.bgColor = primaryColor});
  final VoidCallback callback;
  final String text;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FilledButton(
        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(bgColor)),
        onPressed: callback,
        child: Text(text,
            style: TextStyle(color: color)),
      ),
    );
  }
}
