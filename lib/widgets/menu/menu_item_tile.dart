import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';

class MenuItemTile extends HookConsumerWidget {
  const MenuItemTile({super.key, this.item});
  final RestaurantMenuItem? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}