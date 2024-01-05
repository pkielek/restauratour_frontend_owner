import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'planner_tables_board.dart';

enum CurrentEditAction {
  resizeLeft,
  resizeRight,
  resizeTop,
  resizeBottom,
  move,
  none;

  factory CurrentEditAction.fromResizeDirection(
      PlannerDirection? direction) {
    switch (direction) {
      case PlannerDirection.bottom:
        return resizeBottom;
      case PlannerDirection.left:
        return resizeLeft;
      case PlannerDirection.right:
        return resizeRight;
      case PlannerDirection.top:
        return resizeTop;
      default:
        return move;
    }
  }

  SystemMouseCursor get cursor {
    switch (this) {
      case resizeLeft:
      case resizeRight:
        return SystemMouseCursors.resizeLeftRight;
      case resizeTop:
      case resizeBottom:
        return SystemMouseCursors.resizeUpDown;
      case move:
        return SystemMouseCursors.move;
      case none:
        return SystemMouseCursors.click;
    }
  }
}

abstract class PlannerObject {
  double get left;
  double get top;
  Rect get newRectOffset;
  CurrentEditAction get currentAction;
  Rect toRect([double? precision]);
  Rect toNewRect(double precision);
  Rect toNewCollisionRect(double precision);
  PlannerObject onDragStart(DragStartDetails detail,
      [PlannerDirection? direction]);
  PlannerObject onDragUpdate(DragUpdateDetails details, double precision,
      [PlannerDirection? direction]);
  PlannerObject onDragEnd(DragEndDetails details, double precision);
  PlannerObject resetDrag();
}