import 'package:flutter/material.dart';

import '../../constants.dart';

const boldBig = TextStyle(fontWeight: FontWeight.w700, fontSize: 32);
const footprintStyle = TextStyle(fontWeight: FontWeight.w100, fontSize: 12);
const headerStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 24);
const listStyle = TextStyle(fontWeight: FontWeight.w700, fontSize:18);
const smallDetailStyle = TextStyle(fontWeight: FontWeight.w200, fontSize: 12, color: primaryColor);
const inactiveNavigationButtonText = TextStyle(fontWeight: FontWeight.w300, fontSize: 20, color: Colors.black);
const activeNavigationButtonText = TextStyle(fontWeight: FontWeight.w700, fontSize: 20);

const headerLeftDivider = Divider(color: Colors.black, thickness: 3, endIndent: 10);
const headerDivider = Divider(color: Colors.black, thickness: 3, indent: 10, endIndent: 10);



Color navigationColor(Set<MaterialState> states) {
  if(states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
    return primaryColor;
  } else {
    return Colors.black;
  }
}