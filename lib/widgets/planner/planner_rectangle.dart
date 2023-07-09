import 'package:flutter/material.dart';
import 'package:restaurant_helper/widgets/planner/planner_base_shape.dart';

import '../../model/planner_object.dart';

class PlannerRectangle extends PlannerBaseShape {
  const PlannerRectangle(this.object, {Key? key}) : super(key: key);
  final PlannerObject object;
  @override
  _PlannerRectangleState createState() => _PlannerRectangleState();
}

class _PlannerRectangleState extends PlannerBaseShapeState<PlannerRectangle> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.object.position.dx,
      top: widget.object.position.dy,
      child: Container(
        width: widget.object.width,
        height: widget.object.height,
        decoration:
            BoxDecoration(border: Border.all(width: 2, color: Colors.black)),
      ),
    );
  }
}
