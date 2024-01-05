import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/planner_border.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/planner/planner_panel_button.dart';

class PlannerPanelChooseBorderType extends ConsumerWidget {
  const PlannerPanelChooseBorderType({super.key, required this.board});
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
              "Wybierz kolejny typ granicy do ustawienia. By zakończyć ustawianie granic, zamknij obwód granicy restauracji",
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center)
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final type in PlannerBorderType.values)
            PlannerPanelButton(
                callback: () => ref
                    .read(plannerBoardProvider.notifier)
                    .chooseNewBorderType(type),
                text: type.label,
                bgColor: type.color)
        ]),
        Column(
          children: [
            if(board.borders.length>1)
              PlannerPanelButton(
                  text: "Usuń ostatnią granicę",
                  callback:
                      ref.read(plannerBoardProvider.notifier).removeLastBorder),
            PlannerPanelButton(
              text: "Pozostaw granice puste",
              callback: ref.read(plannerBoardProvider.notifier).stopAddBorder,
            ),
            PlannerPanelButton(
              text: "Pozostaw poprzednie",
              callback: ref.read(plannerBoardProvider.notifier).resetBorders,
            )
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
