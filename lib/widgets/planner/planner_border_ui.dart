import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/planner_tables_board.dart';
import '../../model/planner_border.dart';

class PlannerBorderUI extends ConsumerWidget {
  const PlannerBorderUI(
      {super.key,
      required this.data,
      required this.board,
      required this.index});
  final PlannerTablesBoard board;
  final PlannerBorder data;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardNotifier = ref.watch(plannerBoardProvider.notifier);
    final BoxDecoration decoration = BoxDecoration(color: data.type.color);

    return Stack(
      fit: StackFit.expand,
      children: [
        
        Positioned.fromRect(
          rect: data.toRect(board.precision),
          child: Container(
            decoration: decoration,
          ),
        ),
        Positioned.fromRect(
          rect: data.toNewRect(board.precision),
          child: Container(
            decoration: decoration,
          ),
        ),
        if (board.currentAction == BoardAction.chooseExtendBorder &&
            index + 1 == board.borders.length)
          for (final direction in PlannerDirection.values)
            if (board.canExtendBorderInDirection(index, direction) || (index > 0 && data.left>=0))
              Positioned.fromRect(
                  rect: board.borders[index-1>0?index-1:0].toExtendRect(
                      board.precision, direction, onEnd: board.extendBorderOnEnd()),
                  child: Opacity(
                    opacity: index > 0 && data.left >= 0 ? 0 : 0.33,
                    child: Container(
                        decoration: decoration,
                        width: board.precision,
                        height: board.precision,
                        child: MouseRegion(
                            cursor: direction.isHorizontal
                                ? SystemMouseCursors.resizeLeftRight
                                : SystemMouseCursors.resizeUpDown,
                            child: GestureDetector(
                              onPanStart: (details) => boardNotifier
                                  .onBorderDragStart(details, direction),
                              onPanUpdate: (details) => boardNotifier
                                  .onBorderDragUpdate(details, direction),
                              onPanEnd: (details) => boardNotifier
                                  .onBorderDragEnd(details, direction),
                            ))),
                  ))
      ],
    );
  }
}
