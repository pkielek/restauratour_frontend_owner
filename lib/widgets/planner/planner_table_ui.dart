import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/planner_object.dart';
import 'package:restaurant_helper/widgets/planner/planner_table_resize_handle.dart';

import '../../model/planner_tables_board.dart';
import '../../model/planner_table.dart';

class PlannerTableUI extends ConsumerWidget {
  const PlannerTableUI({super.key, required this.data, required this.board});
  final PlannerTablesBoard board;
  final PlannerTable data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardNotifier = ref.watch(plannerBoardProvider.notifier);
    final BoxDecoration decoration = BoxDecoration(
        color: board.isSelectedTable(data) ? Colors.green : Colors.red,
        border: Border.all(color: Colors.black, width: 2));
    final Container chair = Container(
        width:board.precision,
        height:board.precision,
        decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(50)));

    final uneditableTableWidget =
        !board.editable ? Container(decoration: decoration) : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (board.editable)
          Positioned.fromRect(
            rect: data.toNewRect(board.precision),
            child: MouseRegion(
              cursor: data.currentAction.cursor,
              child: Opacity(
                  opacity: !data.isDragged || board.canUpdateTable(data.id, isTable: true) ? 1 : 0,
                  child: Container(
                    decoration: decoration,
                  )),
            ),
          ),
        if (data.seatsTop > 0)
          Positioned(
              left: data.left,
              top: data.top - board.precision,
              width: data.width,
              height: board.precision,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.filled(data.seatsTop, chair))),
        if (data.seatsBottom > 0)
          Positioned(
              left: data.left,
              top: data.top+data.height,
              width: data.width,
              height: board.precision,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.filled(data.seatsBottom, chair))),
        if (data.seatsLeft > 0)
          Positioned(
              left: data.left - board.precision,
              top: data.top,
              width: board.precision,
              height: data.height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.filled(data.seatsLeft, chair))),
        if (data.seatsRight > 0)
          Positioned(
              left: data.left + data.width,
              top: data.top,
              width: board.precision,
              height: data.height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.filled(data.seatsRight, chair))),
        Positioned.fromRect(
            rect: data.toRect(),
            child: uneditableTableWidget ??
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    MouseRegion(
                      cursor: data.currentAction.cursor,
                      child: GestureDetector(
                        onTap: board.currentAction == BoardAction.none ? () => boardNotifier.selectTable(data) : null,
                        onPanStart: board.selectedTable != null
                            ? null
                            : (details) => boardNotifier.onTableDragStart(
                                data.id, details),
                        onPanUpdate: board.selectedTable != null
                            ? null
                            : (details) => boardNotifier.onTableDragUpdate(
                                data.id, details),
                        onPanEnd: board.selectedTable != null
                            ? null
                            : (details) =>
                                boardNotifier.onTableDragEnd(data.id, details),
                        child: Opacity(
                          opacity: 0.33,
                          child: Container(
                            decoration: decoration,
                          ),
                        ),
                      ),
                    ),
                    if (board.selectedTable == null)
                      for (final direction in PlannerDirection.values)
                        PlannerTableResizeHandle(
                            rect: data.toRect(),
                            id: data.id,
                            direction: direction,
                            precision: board.precision)
                  ],
                )),
      ],
    );
  }
}
