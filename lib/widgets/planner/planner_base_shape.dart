import 'package:flutter/material.dart';

class PlannerBaseShape extends StatefulWidget {
  const PlannerBaseShape({super.key});

  @override
  PlannerBaseShapeState createState() => PlannerBaseShapeState();
}

class PlannerBaseShapeState<T extends PlannerBaseShape> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
