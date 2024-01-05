import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper/model/planner_object.dart';

import 'planner_tables_board.dart';

part 'planner_border.freezed.dart';
part 'planner_border.g.dart';

enum PlannerBorderType {
  @JsonValue("Ściana")
  wall,
  @JsonValue("Okno")
  window,
  @JsonValue("Drzwi")
  door;

  Color get color {
    switch (this) {
      case window:
        return Colors.cyan;
      case door:
        return Colors.brown;
      case wall:
        return Colors.black;
    }
  }

  String get label {
    switch (this) {
      case wall:
        return 'Ściana';
      case door:
        return 'Drzwi';
      case window:
        return 'Okno';
    }
  }
}

@freezed
class PlannerBorder with _$PlannerBorder implements PlannerObject {
  const PlannerBorder._();

  factory PlannerBorder(
      {required double left,
      required double top,
      required bool isHorizontal,
      required double length,
      required PlannerBorderType type,
      @JsonKey(ignore: true) @Default(false) bool isDragged,
      @JsonKey(ignore: true) @Default(Rect.zero) Rect newRectOffset,
      @JsonKey(ignore: true)
      @Default(CurrentEditAction.none)
      CurrentEditAction currentAction}) = _PlannerBorder;

  factory PlannerBorder.fromJson(Map<String, dynamic> json) =>
      _$PlannerBorderFromJson(json);

  @override
  Rect toRect([double? precision]) {
    return Rect.fromLTWH(left, top, isHorizontal ? length : precision!,
        isHorizontal ? precision! : length);
  }

  @override
  Rect toNewRect(double precision) {
    double newLeft = left + (newRectOffset.left ~/ precision) * precision;
    if (currentAction == CurrentEditAction.resizeLeft) {
      newLeft = min(left + length - precision, newLeft);
    }
    double newTop = top + (newRectOffset.top ~/ precision) * precision;
    if (currentAction == CurrentEditAction.resizeTop) {
      newTop = min(top + length - precision, newTop);
    }
    return Rect.fromLTWH(
        newLeft,
        newTop,
        isHorizontal
            ? max(length + (newRectOffset.width ~/ precision) * precision,
                precision)
            : precision,
        isHorizontal
            ? precision
            : max(length + (newRectOffset.height ~/ precision) * precision,
                precision));
  }

  @override
  Rect toNewCollisionRect(double precision) => toNewRect(precision);

  Rect toExtendRect(double precision, PlannerDirection direction, {required bool onEnd}) {
    return Rect.fromLTWH(
        left +
            (direction.isHorizontal
                ? precision * direction.sizeMultiplier
                : 0) +
            (isHorizontal && onEnd ? length - precision : 0),
        top +
            (direction.isVertical ? precision * direction.sizeMultiplier : 0) +
            (!isHorizontal && onEnd ? length - precision : 0),
        precision,
        precision);
  }

  Rect toBroadenedRect(double precision) {
    return Rect.fromLTWH(
      left - (isHorizontal ? precision : 0),
      top - (!isHorizontal ? precision : 0),
      isHorizontal ? length + 2 * precision : precision,
      isHorizontal ? precision : length + 2 * precision,
    );
  }

  @override
  PlannerBorder onDragStart(DragStartDetails detail,
      [PlannerDirection? direction]) {
    return copyWith(
        isHorizontal: direction!.isHorizontal,
        newRectOffset: Rect.zero,
        isDragged: true,
        currentAction: CurrentEditAction.fromResizeDirection(direction));
  }

  PlannerBorder onPlaceAndDragStart(
      DragStartDetails detail, PlannerDirection direction, Rect startPosition) {
    return copyWith(
        left: startPosition.left,
        top: startPosition.top,
        length: startPosition.height,
        isHorizontal: direction.isHorizontal,
        newRectOffset: Rect.zero,
        isDragged: true,
        currentAction: CurrentEditAction.fromResizeDirection(direction));
  }

  @override
  PlannerBorder onDragUpdate(DragUpdateDetails details, double precision,
      [PlannerDirection? direction]) {
    final offsetLeft = direction == PlannerDirection.left
        ? newRectOffset.left + details.delta.dx
        : 0.0;
    final offsetTop = direction == PlannerDirection.top
        ? newRectOffset.top + details.delta.dy
        : 0.0;
    double offsetWidth = direction!.isHorizontal || !isHorizontal
        ? newRectOffset.width + direction.sizeMultiplier * details.delta.dx
        : 0.0;
    double offsetHeight = direction!.isVertical || isHorizontal
        ? newRectOffset.height + direction.sizeMultiplier * details.delta.dy
        : 0.0;
    final newOffset =
        Rect.fromLTWH(offsetLeft, offsetTop, offsetWidth, offsetHeight);
    return copyWith(newRectOffset: newOffset);
  }

  @override
  PlannerBorder onDragEnd(DragEndDetails details, double precision) {
    final newRect = toNewRect(precision);
    return copyWith(
        newRectOffset: Rect.zero,
        left: newRect.left,
        top: newRect.top,
        length: isHorizontal ? newRect.width : newRect.height,
        isDragged: false,
        currentAction: CurrentEditAction.none);
  }

  PlannerBorder updateAddBorder(PointerHoverEvent event, double precision) {
    return copyWith(
        newRectOffset: Rect.fromLTWH(event.localPosition.dx + precision,
            event.localPosition.dy + precision, 0, 0));
  }

  PlannerBorder updateBorderType(PlannerBorderType type) => copyWith(type: type);

  @override
  PlannerBorder resetDrag() => copyWith(newRectOffset: Rect.zero, isDragged: false);
}
