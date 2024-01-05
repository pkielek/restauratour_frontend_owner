import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/auth.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';

class PlannerTableResizeHandle extends ConsumerWidget {
  const PlannerTableResizeHandle(
      {super.key, required this.rect, required this.direction, required this.id, required this.precision});
  final Rect rect;
  final String id;
  final double precision;
  final PlannerDirection direction;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
        top: direction.isHorizontal ? 0.5 * precision : (direction==PlannerDirection.bottom ? rect.height-0.5*precision : 0) ,
        left: direction.isVertical ? 0.5 * precision : (direction==PlannerDirection.right ? rect.width-0.5*precision : 0),
        child: SizedBox(
            width: direction.isHorizontal
                ? 0.5*precision
                : rect.width - precision,
            height: direction.isVertical
                ? 0.5*precision
                : rect.height - precision,
            child: MouseRegion(
                cursor: direction.isHorizontal
                    ? SystemMouseCursors.resizeLeftRight
                    : SystemMouseCursors.resizeUpDown,child: GestureDetector(
                      onPanStart:
                          (details) => ref.read(PlannerInfoProvider(AuthType.owner).notifier).onTableDragStart(id, details, direction),
                      onPanUpdate:
                          (details) => ref.read(PlannerInfoProvider(AuthType.owner).notifier).onTableDragUpdate(id, details, direction),
                      onPanEnd: 
                          (details) => ref.read(PlannerInfoProvider(AuthType.owner).notifier).onTableDragEnd(id, details),
                    ))));
  }
}
