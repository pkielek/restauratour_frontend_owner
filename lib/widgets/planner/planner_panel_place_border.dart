import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/planner/planner_panel_button.dart';

class PlannerPanelPlaceBorder extends ConsumerWidget {
  const PlannerPanelPlaceBorder(
      {super.key, required this.board, required this.placed, required this.notFirst});
  final PlannerTablesBoard board;
  final bool placed;
  final bool notFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
          const Text("Witaj w RestauraTOUR",
              style: headerStyle, textAlign: TextAlign.center),
          Text(
              placed ? "Poszerz ${notFirst ? "kolejną" : "pierwszą"} ścianę granicy pociągając za odpowiednią stronę" : "Ustaw nowy stolik w wybranym miejscu",
              style: const TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center)
        ]),
        Column(
          children: [
            if(notFirst)
            PlannerPanelButton(
                text: "Usuń ostatnią granicę",
                callback:
                    ref.read(plannerBoardProvider.notifier).removeLastBorder),
            PlannerPanelButton(
                  text: "Pozostaw granice puste",
                  callback: ref.read(plannerBoardProvider.notifier).stopAddBorder,
                ),
            PlannerPanelButton(
              text:"Pozostaw poprzednie",
              callback: ref.read(plannerBoardProvider.notifier).resetBorders,
            )
          ],
        ),
        const SizedBox(height:10)
      ],
    );
  }
}
