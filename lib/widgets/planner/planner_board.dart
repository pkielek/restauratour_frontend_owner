import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/widgets/planner/planner_table_ui.dart';

import '../../model/planner_tables_board.dart';
import 'planner_border_ui.dart';

class PlannerBoard extends ConsumerWidget {
  const PlannerBoard({super.key, required this.board});
  final PlannerTablesBoard board;

  List<Widget> getUninitalizedBoardShapes(
      BoxConstraints constraints, double precision) {
    if (precision < 0) {
      precision = 15.0;
    }
    final p = precision;
    final w = (0.05 * constraints.maxWidth * p) ~/ p;
    final h = (0.05 * constraints.maxHeight * p) ~/ p;
    return [
      Positioned(
          left: 7.0 * w,
          top: 10.0 * h,
          width: 3.0 * w,
          height: p,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(color: Colors.black, width: 2)))),
      Positioned(
          left: 12.0 * w,
          top: 6 * h + 2 * p,
          width: 3 * w - p,
          height: 8 * h - 3 * p,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(color: Colors.black, width: 2)))),
      Positioned(
          left: 5.0 * w,
          top: 6 * h + p,
          height: 8 * h - p,
          width: p,
          child: Container(color: Colors.black)),
      Positioned(
          left: 15.0 * w,
          top: 6 * h + p,
          height: 8.0 * h,
          width: p,
          child: Container(color: Colors.black)),
      Positioned(
          left: 5.0 * w,
          top: 6.0 * h,
          height: p,
          width: 10 * w + p,
          child: Container(color: Colors.black)),
      Positioned(
          left: 5.0 * w,
          top: 14.0 * h,
          height: p,
          width: 10.0 * w,
          child: Container(color: Colors.black)),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref
          .read(plannerBoardProvider.notifier)
          .updateConstraints(constraints));
      return InteractiveViewer(
        child: GridPaper(
            color: Colors.black.withAlpha(15),
            divisions: 1,
            subdivisions: 1,
            interval: board.precision < 0 ? 15 : board.precision,
            child: GestureDetector(
              onTap: !board.editable
                  ? null
                  : board.currentAction == BoardAction.addTable
                      ? ref.read(plannerBoardProvider.notifier).placeNewTable
                      : (board.currentAction == BoardAction.placeBorder
                          ? ref
                              .read(plannerBoardProvider.notifier)
                              .placeNewBorder
                          : (board.currentAction == BoardAction.tableInfo
                              ? ref
                                  .read(plannerBoardProvider.notifier)
                                  .deselectTable
                              : null)),
              child: MouseRegion(
                onHover: !board.editable
                    ? null
                    : (board.currentAction == BoardAction.addTable
                        ? ref.read(plannerBoardProvider.notifier).updateAddTable
                        : (board.currentAction == BoardAction.placeBorder
                            ? ref
                                .read(plannerBoardProvider.notifier)
                                .updatePlaceBorder
                            : null)),
                cursor: !board.editable
                    ? MouseCursor.defer
                    : board.currentAction?.cursor ?? MouseCursor.defer,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ...board.tables.map(
                      (e) => PlannerTableUI(data: e, board: board),
                    ),
                    if (board.editable &&
                        board.status == BoardStatus.uninitialized)
                      ...getUninitalizedBoardShapes(
                          constraints, board.precision),
                    ...board.borders.indexed.map((entry) => PlannerBorderUI(
                          data: entry.$2,
                          board: board,
                          index: entry.$1,
                        ))
                  ],
                ),
              ),
            )),
      );
    });
  }
}
