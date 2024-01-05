import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/model/auth.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/planner/planner_panel_button.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class PlannerPanelDefault extends ConsumerWidget {
  PlannerPanelDefault({super.key, required this.board});
  final PlannerTablesBoard board;
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
          const Text("Witaj w RestauraTOUR",
              style: headerStyle, textAlign: TextAlign.center),
          Text(
              board.status == BoardStatus.uninitialized
                  ? "Rozpocznij od ustawienia precyzji planu swojej restauracji."
                  : "Dodaj ${board.status == BoardStatus.empty ? "pierwsze" : "kolejne"} elementy swojego planu restauracji.",
              style: const TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center)
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!(board.status == BoardStatus.uninitialized)) ...[
            PlannerPanelButton(
              text: "Dodaj stolik",
              callback: ref
                  .read(PlannerInfoProvider(AuthType.owner).notifier)
                  .addTable,
            ),
            PlannerPanelButton(
              text: "${board.borders.isEmpty ? "Dodaj" : "Zmień"} granice",
              callback: ref
                  .read(PlannerInfoProvider(AuthType.owner).notifier)
                  .placeBorder,
            )
          ],
          Slider(
            value: board.precision < 15 ? 15 : board.precision,
            onChanged: ref
                .read(PlannerInfoProvider(AuthType.owner).notifier)
                .updatePrecision,
            min: 15,
            max: 50,
            label: "Precyzja: ${board.precision.toString()}",
            divisions: 35,
          )
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (board.status == BoardStatus.standard)
            PlannerPanelButton(
                callback: ref
                    .read(PlannerInfoProvider(AuthType.owner).notifier)
                    .resetChanges,
                text: "Zresetuj zmiany"),
          RoundedLoadingButton(
            color: primaryColor,
            successIcon: Icons.done,
            failedIcon: Icons.close,
            resetAfterDuration: true,
            resetDuration: const Duration(seconds: 2),
            width: 2000,
            controller: _submitController,
            onPressed: () => board.status == BoardStatus.empty
                ? ref
                    .read(PlannerInfoProvider(AuthType.owner).notifier)
                    .savePrecision()
                : ref
                    .read(PlannerInfoProvider(AuthType.owner).notifier)
                    .saveChanges(),
            child: Text(
                'Zapisz ${board.status == BoardStatus.empty ? "precyzję" : "zmiany"}',
                style: const TextStyle(color: Colors.white)),
          )
        ])
      ],
    );
  }
}
