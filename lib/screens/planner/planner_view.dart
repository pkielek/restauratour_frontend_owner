import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/auth.dart';
import 'package:restaurant_helper/model/planner_tables_board.dart';
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:restaurant_helper/widgets/planner/planner_board.dart';
import 'package:restaurant_helper/widgets/planner/planner_board_panel.dart';
import 'package:utils/utils.dart';

class PlannerView extends ConsumerWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(PlannerInfoProvider(AuthType.owner));
    final notifier = ref.read(PlannerInfoProvider(AuthType.owner).notifier);
    return BaseView(
        screen: provider.when(
            data: (board) {
              return Row(
                children: [
                  Expanded(
                    child: PlannerBoard(board: board, notifier: notifier),
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
