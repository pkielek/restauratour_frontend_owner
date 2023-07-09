import 'package:flutter/material.dart';
import 'package:restaurant_helper/screens/login/login_view.dart';
import 'package:restaurant_helper/screens/space_planner/space_planner_view.dart';
import 'package:routemaster/routemaster.dart';

final routes = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView())
});