import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_helper/model/worker.dart';
import 'package:utils/utils.dart';

class WorkerListButtons extends ConsumerWidget {
  const WorkerListButtons(this.workerData, {super.key});
  final Worker workerData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        workerData.status != AccountStatus.blocked
            ? IconButton(
                onPressed: () => ref
                    .read(workerListProvider.notifier)
                    .workerAction(
                        workerData.id, 'resend-worker-activation-link'),
                icon: const Icon(Icons.key),
                splashRadius: 24,
                iconSize: 24,
                color: Colors.yellow,
                tooltip: workerData.status == AccountStatus.active
                    ? 'Zresetuj hasło'
                    : "Wyślij nowy klucz aktywacyjny")
            : IconButton(
                onPressed: () => ref
                    .read(workerListProvider.notifier)
                    .workerAction(workerData.id, 'enable-worker'),
                icon: const Icon(Icons.lock_open),
                splashRadius: 24,
                iconSize: 24,
                color: Colors.green,
                tooltip: "Odblokuj kelnera"),
        if (workerData.status == AccountStatus.active)
          IconButton(
              onPressed: () => ref
                  .read(workerListProvider.notifier)
                  .workerAction(workerData.id, 'disable-worker'),
              icon: const Icon(Icons.lock_open),
              splashRadius: 24,
              iconSize: 24,
              color: Colors.red,
              tooltip: "Zablokuj kelnera"),
        IconButton(
            onPressed: () => showDialog(
                  context: context,
                  builder: (context) => DefaultDialog(
                      title: "Usuń kelnera",
                      text:
                          "Czy na pewno chcesz usunąć kelnera ${workerData.firstName} ${workerData.surname}?",
                      onConfirm: () {
                        ref
                            .read(workerListProvider.notifier)
                            .workerAction(workerData.id, 'remove-worker');
                        Navigator.pop(context, 'Usuń');
                      },
                      confirmText: "Usuń"),
                ),
            icon: const Icon(Icons.delete),
            splashRadius: 24,
            iconSize: 24,
            color: Colors.grey,
            tooltip: "Usuń kelnera")
      ],
    );
  }
}
