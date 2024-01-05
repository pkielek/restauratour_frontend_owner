import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/planner/planner_panel_button.dart';

import '../../constants.dart';

class PlannerPanelTableInfo extends HookConsumerWidget {
  const PlannerPanelTableInfo({super.key, required this.board});
  final PlannerTablesBoard board;

  Positioned tableButton(
      WidgetRef ref, PlannerDirection direction, double left, double top,
      {bool subtract = false}) {
    final pressable = subtract
        ? board.canSubtractChairs(direction)
        : board.canAddChairs(direction);
    return Positioned(
        left: left,
        top: top,
        width: 30,
        height: 30,
        child: IconButton(
            icon: Icon(subtract ? Icons.remove_circle : Icons.add_circle,
                color: pressable ? primaryColor : Colors.grey),
            padding: const EdgeInsets.all(0),
            iconSize: 30,
            constraints: const BoxConstraints(),
            onPressed: pressable
                ? () => ref
                    .read(plannerBoardProvider.notifier)
                    .modifyChairs(direction, subtract)
                : null));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableIdController= useTextEditingController(text: board.tables[board.selectedTable!].id);
    ref.listen(plannerBoardProvider.select((value) => value.value!.selectedTable),(prev,next) => tableIdController.text = next.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(children: [
          Text("Witaj w RestauraTOUR",
              style: headerStyle, textAlign: TextAlign.center),
          Text("Ustaw szczegóły stolika - krzesła i identyfikator",
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center)
        ]),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
                onChanged: null,
                controller: tableIdController,
                onEditingComplete: () => ref.read(plannerBoardProvider.notifier).updateTableID(tableIdController),
                onTapOutside: (event) => ref.read(plannerBoardProvider.notifier).updateTableID(tableIdController),
                decoration: InputDecoration(
                  labelText: 'Identyfikator stolika (unikalny)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                )),
            const Padding(padding: EdgeInsets.symmetric(vertical:8)),
            SizedBox(
                width: 160,
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fromRect(
                        rect: const Rect.fromLTWH(30, 30, 100, 200),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.all(
                                    color: Colors.black, width: 2)))),
                    tableButton(ref, PlannerDirection.top, 50, 0),
                    tableButton(ref, PlannerDirection.top, 80, 0, subtract: true),
                    tableButton(ref, PlannerDirection.left, 0, 100),
                    tableButton(ref, PlannerDirection.left, 0, 130, subtract: true),
                    tableButton(ref, PlannerDirection.right, 130, 100),
                    tableButton(ref, PlannerDirection.right, 130, 130,subtract: true),
                    tableButton(ref, PlannerDirection.bottom, 50, 230),
                    tableButton(ref, PlannerDirection.bottom, 80, 230, subtract: true),
                  ],
                )),
          ],
        ),
        PlannerPanelButton(
            callback: ref.read(plannerBoardProvider.notifier).deselectTable,
            text: "Zakończ zmiany")
      ],
    );
  }
}
