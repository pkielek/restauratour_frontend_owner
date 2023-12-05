import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:routemaster/routemaster.dart';

class NavigationItem extends ConsumerWidget {
  const NavigationItem(
      {super.key,
      required this.routeName,
      required this.route,
      required this.currentRoute});

  final String routeName;
  final String route;
  final bool currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
        onPressed: () => Routemaster.of(context).push(route),
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(currentRoute
                ? activeNavigationButtonText
                : inactiveNavigationButtonText),
            foregroundColor: currentRoute
                ? MaterialStateProperty.all(primaryColor)
                : MaterialStateProperty.resolveWith(
                    (states) => navigationColor(states))),
        child: Text(routeName));
  }
}
