import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

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
        onPressed: () =>
            ref.read(unsavedChangesProvider.notifier).state == false
                ? Routemaster.of(context).push(route)
                : showDialog(
                    context: context,
                    builder: (context) => DefaultDialog(
                        title: "Niezapisane zmiany",
                        text:
                            "Obecny widok ma niezapisane zmiany, czy chcesz kontynuować?",
                        onConfirm: () {
                          Navigator.pop(context, 'Tak');
                          Routemaster.of(context).push(route);
                          ref.read(unsavedChangesProvider.notifier).state =
                              false;
                        }),
                  ),
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all(currentRoute
                ? activeNavigationButtonText
                : inactiveNavigationButtonText),
            foregroundColor: currentRoute
                ? MaterialStateProperty.all(primaryColor)
                : MaterialStateProperty.resolveWith(navigationColor)),
        child: Text(routeName));
  }
}
