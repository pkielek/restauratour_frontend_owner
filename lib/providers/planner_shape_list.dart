import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_helper/model/planner_object.dart';

class PlannerShapeListNotifier extends StateNotifier<List<PlannerObject>> {
  PlannerShapeListNotifier() : super([]) {
    addObject(PlannerObject(
        id: "1", position: const Offset(0, 0), width: 80, height: 200));
    addObject(PlannerObject(
        id: "2", position: const Offset(80, 200), width: 800, height: 200));
  }

  void addObject(PlannerObject obj) {
    state = [...state, obj];
  }
}

final plannerShapeListProvider =
    StateNotifierProvider<PlannerShapeListNotifier, List<PlannerObject>>((ref) {
  return PlannerShapeListNotifier();
});
