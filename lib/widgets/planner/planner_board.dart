import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_helper/providers/planner_shape_list.dart';
import 'package:restaurant_helper/widgets/planner/planner_rectangle.dart';

import '../../model/planner_object.dart';

class PlannerBoard extends ConsumerStatefulWidget {
  const PlannerBoard({Key? key}) : super(key: key);

  @override
  _PlannerBoardState createState() => _PlannerBoardState();
}

class _PlannerBoardState extends ConsumerState<PlannerBoard> {
  @override
  Widget build(BuildContext context) {
    final List<PlannerObject> objects = ref.watch(plannerShapeListProvider);
    return InteractiveViewer(
        child: Stack(
            alignment: AlignmentDirectional.center,
            children: objects.map((obj) => PlannerRectangle(obj)).toList()));
  }
}
