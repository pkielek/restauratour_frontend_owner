import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';
import 'package:utils/utils.dart';

class MenuItemEditDialog extends HookConsumerWidget {
  const MenuItemEditDialog(
      {super.key, this.item, required this.padding, required this.onConfirm});
  final RestaurantMenuItem? item;
  final VoidCallback onConfirm;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editedItem = item?.copyWith() ??
        RestaurantMenuItem(
            id: -1,
            name: "",
            description: "",
            price: 0.00,
            order: -1,
            status: RestaurantMenuItemType.available,
            photoUrl: "");
    return AlertDialog(
        title: Column(
          children: [
            Text(
              item != null ? "Edytuj" : "Dodaj pozycję",
              style: headerStyle,
            ),
            headerDivider
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        //             TextFormField(
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        // initialValue: editedItem.name,
        // validator: (input) {
        //   if (input == "" || input==null) return null;
        //   return input.length > 3 ? null : "Długość nazwy musi być większa lub równa 3";
        // },
        // onChanged: (value) => editedItem.name = value,
        // decoration: defaultDecoration(
        //     icon: Icons.person, labelText: labelText ?? 'Adres e-mail'))
              ]),
        ),
        insetPadding: padding,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              color: Colors.indigo,
              tooltip: "Zapisz zmiany",
              onPressed: () {
                onConfirm();
                Navigator.pop(context, "Zapisz zmiany");
              }),
          IconButton(
              icon: const Icon(Icons.cancel),
              color: primaryColor,
              tooltip: "Anuluj",
              onPressed: () => Navigator.pop(context, 'Anuluj'))
        ]);
  }
}
