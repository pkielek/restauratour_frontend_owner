import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart'
    hide PlannerBoard;
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:restaurant_helper/widgets/helper/loading.dart';
import 'package:restaurant_helper/widgets/planner/planner_board.dart';
import 'package:restaurant_helper/widgets/planner/planner_board_panel.dart';

class PlannerView extends ConsumerWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseView(
        screen: ref.watch(plannerBoardProvider).when(
            data: (board) {
              return Row(
                children: [
                  Expanded(
                    child: PlannerBoard(board: board),
                  ),
                  PlannerBoardPanel(board: board)
                ],
              );
            },
            error: (error, stackTrace) =>
                const Loading("Coś poszło nie tak. Spróbuj ponownie później"),
            loading: () =>
                const Loading("Trwa ładowanie planu restauracji...")));
  }
}
