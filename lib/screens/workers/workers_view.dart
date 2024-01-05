import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/workers/create_worker_form.dart';

import '../../model/worker.dart';
import '../../widgets/workers/worker_list.dart';

class WorkersView extends ConsumerWidget {
  const WorkersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    double widthPadded = size.width * 0.8;
    return BaseView(
        screen: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: widthPadded * 0.75,
          padding: const EdgeInsets.only(top: 25),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Lista kelnerów", style: headerStyle),
                IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(right: 10),
                    onPressed: ref.read(workerListProvider.notifier).refresh,
                    icon: const Icon(Icons.refresh),
                    splashRadius: 20,
                    iconSize: 24,
                    color: Colors.black,
                    tooltip: "Odśwież listę")
              ],
            ),
            headerLeftDivider,
            const Expanded(child: WorkersList())
          ]),
        ),
        Container(
          width: widthPadded * 0.25,
          padding: const EdgeInsets.only(top: 25),
          child: Column(children: [
            const Text("Dodaj kelnera", style: headerStyle),
            headerDivider,
            CreateWorkerForm()
          ]),
        )
      ],
    ));
  }
}
