import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';
import 'package:planner/planner.dart';

class PlannerView extends ConsumerWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(PlannerInfoProvider(AuthType.owner));
    final notifier = ref.read(PlannerInfoProvider(AuthType.owner).notifier);
      ref.listen(
        PlannerInfoProvider(AuthType.owner).select((value) => value.when(
            data: (data) => data.isChanged,
            error: (_, __) => false,
            loading: () => false)), (previous, next) {
      ref.read(unsavedChangesProvider.notifier).state = next;
    });
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
            error: (error, stackTrace) {
                return const Loading("Coś poszło nie tak. Spróbuj ponownie później");},
            loading: () =>
                const Loading("Trwa ładowanie planu restauracji...")));
  }
}
