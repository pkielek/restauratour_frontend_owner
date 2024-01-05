import 'package:flutter/material.dart';
import 'package:restaurant_helper/screens/login/login_view.dart';
import 'package:restaurant_helper/screens/workers/workers_view.dart';
import 'package:restaurant_helper/screens/planner/planner_view.dart';
import 'package:restaurant_helper/widgets/helper/loading_screen.dart';
import 'package:routemaster/routemaster.dart';



final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView())
}, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));

final navigationRoutes = {
  '/pulpit': (_) => const MaterialPage(child:PlannerView(),name:'Pulpit'),
  '/menu': (_) => const MaterialPage(child:PlannerView(), name:'Menu'),
  '/kelnerzy': (_) => const MaterialPage(child:WorkersView(), name:'Kelnerzy'),
  '/restauracja': (_) => const MaterialPage(child:PlannerView(), name:'Restauracja'),
};

final routes = RouteMap(routes: {
  '/': (_) => const Redirect('/pulpit'),
  ...navigationRoutes
});