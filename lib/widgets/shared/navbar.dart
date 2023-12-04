import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Navbar extends ConsumerWidget {
  const Navbar(
      {super.key,
      required this.navigationMenu,
      this.profileButton = const SizedBox()});

  final Widget navigationMenu;
  final Widget profileButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final navbarHeight = max(100.0, size.height * 0.15);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: size.width*0.15),
        height: navbarHeight,
        decoration: const BoxDecoration(
            border: BorderDirectional(bottom: BorderSide(width: 1,color:Colors.grey))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(
                  'images/logo.webp',
                  semanticLabel: 'Restaura TOUR Logo',
                  fit: BoxFit.fitHeight,
                ),
              )),
          navigationMenu,
          profileButton
        ]));
  }
}
