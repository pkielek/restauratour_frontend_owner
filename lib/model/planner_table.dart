import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'planner_object.dart';
import 'planner_tables_board.dart';

part 'planner_table.freezed.dart';
part 'planner_table.g.dart';

@freezed
class PlannerTable with _$PlannerTable implements PlannerObject {
  const PlannerTable._();
  factory PlannerTable(
      {@JsonKey(name: "real_id") required String id,
      required double left,
      required double top,
      required double width,
      required double height,
      @Default(0) int seatsTop,
      @Default(0) int seatsLeft,
      @Default(0) int seatsRight,
      @Default(0) int seatsBottom,
      @JsonKey(ignore: true) @Default(false) bool isDragged,
      @JsonKey(ignore: true) @Default(Rect.zero) Rect newRectOffset,
      @JsonKey(ignore: true)
      @Default(CurrentEditAction.none)
      CurrentEditAction currentAction}) = _PlannerTable;

  factory PlannerTable.fromJson(Map<String, dynamic> json) =>
      _$PlannerTableFromJson(json);

  @override
  Rect toRect([double? precision]) => Rect.fromLTWH(left, top, width, height);

  Rect applyTablesToCollision(Rect rect, double precision) {
    return Rect.fromLTWH(
        rect.left - (seatsLeft > 0 ? precision : 0),
        rect.top - (seatsTop > 0 ? precision : 0),
        rect.width +
            (seatsRight > 0 ? precision : 0) +
            (seatsLeft > 0 ? precision : 0),
        rect.height +
            (seatsTop > 0 ? precision : 0) +
            (seatsBottom > 0 ? precision : 0));
  }

  @override
  Rect toNewCollisionRect(double precision) => applyTablesToCollision(toNewRect(precision), precision);
  
  @override
  Rect toNewRect(double precision) {
    double newLeft = left + (newRectOffset.left ~/ precision) * precision;
    if (currentAction == CurrentEditAction.resizeLeft) {
      newLeft = min(left + width - precision, newLeft);
    }
    double newTop = top + (newRectOffset.top ~/ precision) * precision;
    if (currentAction == CurrentEditAction.resizeTop) {
      newTop = min(top + height - precision, newTop);
    }
    return Rect.fromLTWH(
        newLeft,
        newTop,
        max(width + (newRectOffset.width ~/ precision) * precision, precision),
        max(height + (newRectOffset.height ~/ precision) * precision,
            precision));
  }

  @override
  PlannerTable onDragStart(DragStartDetails detail,
      [PlannerDirection? direction]) {
    return copyWith(
        newRectOffset: Rect.zero,
        isDragged: true,
        currentAction: CurrentEditAction.fromResizeDirection(direction));
  }

  @override
  PlannerTable onDragUpdate(DragUpdateDetails details, double precision,
      [PlannerDirection? direction]) {
    late Rect newOffset;
    if (direction == null) {
      newOffset = newRectOffset.shift(details.delta);
    } else {
      final offsetLeft = direction == PlannerDirection.left
          ? newRectOffset.left + details.delta.dx
          : 0.0;
      final offsetTop = direction == PlannerDirection.top
          ? newRectOffset.top + details.delta.dy
          : 0.0;
      double offsetWidth = direction.isHorizontal
          ? newRectOffset.width + direction.sizeMultiplier * details.delta.dx
          : 0.0;
      double offsetHeight = direction.isVertical
          ? newRectOffset.height + direction.sizeMultiplier * details.delta.dy
          : 0.0;
      newOffset =
          Rect.fromLTWH(offsetLeft, offsetTop, offsetWidth, offsetHeight);
    }
    return copyWith(newRectOffset: newOffset);
  }

  @override
  PlannerTable onDragEnd(DragEndDetails details, double precision) {
    final newRect = toNewRect(precision);
    return copyWith(
        newRectOffset: Rect.zero,
        left: newRect.left,
        top: newRect.top,
        width: newRect.width,
        height: newRect.height,
        isDragged: false,
        currentAction: CurrentEditAction.none);
  }

  PlannerTable updateAddTable(PointerHoverEvent event) {
    return copyWith(
        newRectOffset: Rect.fromLTWH(event.localPosition.dx + width,
            event.localPosition.dy + height, 0, 0));
  }

  PlannerTable placeNewTable(double precision, String newId) {
    final newRect = toNewRect(precision);
    return copyWith(
      id: newId,
      newRectOffset: Rect.zero,
      left: newRect.left,
      top: newRect.top,
      width: newRect.width,
      height: newRect.height,
    );
  }

  PlannerTable modifyChairs(
      PlannerDirection direction, double precision, subtract) {
    switch (direction) {
      case PlannerDirection.top:
        return copyWith(seatsTop: seatsTop + (subtract ? -1 : 1));
      case PlannerDirection.bottom:
        return copyWith(seatsBottom: seatsBottom + (subtract ? -1 : 1));
      case PlannerDirection.right:
        return copyWith(seatsRight: seatsRight + (subtract ? -1 : 1));
      case PlannerDirection.left:
        return copyWith(seatsLeft: seatsLeft + (subtract ? -1 : 1));
    }
  }

  @override
  PlannerTable resetDrag() => copyWith(newRectOffset: Rect.zero, isDragged: false);
}
