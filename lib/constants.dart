import 'dart:ui';

import 'package:flutter/material.dart';

const primaryColor = Color(0xffa30015);
const primarySwatch = MaterialColor(0xffa30015, <int, Color>{
  900: primaryColor,
  800: Color(0xFFB21221),
  700: Color(0xFFBF1B28),
  600: Color(0xFFD0252D),
  500: Color(0xFFDF2F2E),
  400: Color(0xFFDC4448),
  300: Color(0xFFD5686B),
  200: Color(0xFFE39194),
  100: Color(0xFFF8C8CE),
  50: Color(0xFFFCE9EC)
});

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}