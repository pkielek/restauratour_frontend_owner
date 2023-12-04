import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant_helper/routes.dart';
import 'package:restaurant_helper/widgets/shared/navbar.dart';
import 'package:restaurant_helper/widgets/shared/navigation_menu.dart';
import 'package:restaurant_helper/widgets/shared/logout_button.dart';

class BaseView extends ConsumerWidget {
  const BaseView({super.key, required this.screen});
  final Widget screen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(
      children: [
        Navbar(
            navigationMenu: NavigationMenu(navigationRoutes: navigationRoutes),
            profileButton: const LogoutButton()),
        Expanded(child: screen)
      ],
    ));
  }
}
