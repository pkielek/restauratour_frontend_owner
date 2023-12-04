import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/widgets/helper/styles.dart';
import 'package:restaurant_helper/widgets/shared/navigation_item.dart';

class NavigationMenu extends ConsumerWidget {
  const NavigationMenu({super.key, required this.navigationRoutes});

  final Map navigationRoutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRouteName = ModalRoute.of(context)!.settings.name;
    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: navigationRoutes.entries
              .map((entry) => NavigationItem(
                  routeName: entry.value('').name,
                  route: entry.key,
                  currentRoute: entry.value('').name == currentRouteName))
              .toList()),
    );
  }
}
