import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/model/worker.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/workers/worker_list_buttons.dart';

class WorkerTile extends ConsumerWidget {
  const WorkerTile(this.workerData, {super.key});
  final Worker workerData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntrinsicHeight(
        child: Container(
      decoration: BoxDecoration(
          color: primaryColor.withAlpha(5),
          border: Border.all(color: primaryColor.withAlpha(20), width: 2),
          borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
              text: TextSpan(
                  text: '${workerData.first_name} ${workerData.surname}',
                  style: listStyle,
                  children: [
                TextSpan(text: '\n${workerData.email}', style: smallDetailStyle)
              ])),
          Text(accountStatusMap[workerData.status]!,
              style: TextStyle(color: accountStatusColorMap[workerData.status], fontWeight: FontWeight.w500, fontSize: 16)),
          WorkerListButtons(workerData)
        ],
      ),
    ));
  }
}
