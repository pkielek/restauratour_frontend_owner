import 'package:flutter/animation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planner_object.freezed.dart';

@freezed
class PlannerObject with _$PlannerObject {
  factory PlannerObject(
      {required String id,
      required Offset position,
      required double width,
      required double height}) = _PlannerObject;
}
