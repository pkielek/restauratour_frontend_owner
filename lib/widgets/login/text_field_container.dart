import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  final String? error;
  final double width;
  const TextFieldContainer({
    Key? key,
    required this.child,
    this.error,
    required this.width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: error != null
          ? const EdgeInsets.only(bottom: 10.0)
          : const EdgeInsets.all(0.0),
      width: size.width * width,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0)),
      child: child,
    );
  }
}
