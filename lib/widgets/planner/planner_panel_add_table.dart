import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/planner/planner_panel_button.dart';

class PlannerPanelAddTable extends ConsumerWidget {
  const PlannerPanelAddTable(
      {super.key, required this.board});
  final PlannerTablesBoard board;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(children: [
          Text("Witaj w RestauraTOUR",
              style: headerStyle, textAlign: TextAlign.center),
          Text(
              "Ustaw nowy stolik w wybranym miejscu",
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center)
        ]),
        PlannerPanelButton(
              text: "Anuluj dodawanie stolika",
              callback: ref.read(plannerBoardProvider.notifier).stopAddTable,
            ),
        const SizedBox(height:10)
      ],
    );
  }
}
