import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_helper/model/worker.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/workers/worker_tile.dart';

class WorkersList extends ConsumerWidget {
  const WorkersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(workerListProvider).when(
        data: (data) {
          if (data.length == 0) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top:10)),
                    const Text("Nie posiadasz jeszcze kelnerów - dodaj pierwszego!",style:boldBig),
                    Image.asset(
                      'images/empty-list-colored.webp',
                      height:MediaQuery.of(context).size.height*0.5
                    ),
                    const Text("© Storyset, Freepik", style: footprintStyle),
                  ],
                ),
              ],
            );
          }
          return ListView.builder(
              padding: const EdgeInsets.only(right: 10),
              shrinkWrap: true,
              itemBuilder: (context, index) => WorkerTile(data[index]),
              itemCount: data.length);
        },
        error: (error, stackTrace) =>
            Text(error.toString(), style: headerStyle),
        loading: () => const Text("Trwa ładowanie...", style: headerStyle));
  }
}
