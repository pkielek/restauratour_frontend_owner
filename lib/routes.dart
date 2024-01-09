import 'package:flutter/material.dart';
import 'package:restaurant_helper/screens/info_view.dart';
import 'package:restaurant_helper/screens/login_view.dart';
import 'package:restaurant_helper/screens/menu_view.dart';
import 'package:restaurant_helper/screens/workers_view.dart';
import 'package:restaurant_helper/screens/planner_view.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';



final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView())
}, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));

final navigationRoutes = {
  '/pulpit': (_) => const MaterialPage(child:PlannerView(),name:'Plan restauracji'),
  '/menu': (_) => const MaterialPage(child:MenuView(), name:'Menu'),
  '/kelnerzy': (_) => const MaterialPage(child:WorkersView(), name:'Kelnerzy'),
  '/restauracja': (_) => const MaterialPage(child:InfoView(), name:'Ustawienia'),
};

final routes = RouteMap(routes: {
  '/': (_) => const Redirect('/pulpit'),
  ...navigationRoutes
});