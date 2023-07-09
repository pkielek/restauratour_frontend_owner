import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/planner/planner_board.dart';

class SpacePlannerView extends ConsumerWidget {
  const SpacePlannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Title'),
        ),
        body: const PlannerBoard());
    // return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Title'),
    //     ),
    //     body: Container(
    //         child: Center(
    //       child: Draggable(
    //         feedback: Container(
    //           width: 100,
    //           height: 10022222222222222,
    //           color: Colors.red,
    //         ),
    //         child: Container(
    //           decoration: const BoxDecoration(
    //               color: Colors.red,
    //               borderRadius: BorderRadius.all(Radius.circular(100))),
    //           width: 100,
    //           height: 100,
    //         ),
    //         onDragStarted: () => {ref},
    //       ),
    //     )));
  }
}
