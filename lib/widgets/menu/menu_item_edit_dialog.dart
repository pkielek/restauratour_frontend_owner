import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';
import 'package:restaurant_helper/widgets/menu/menu_upload_photo_tile.dart';
import 'package:utils/utils.dart';

class MenuItemEditDialog extends ConsumerWidget {
  const MenuItemEditDialog(
      {super.key,
      required this.item,
      required this.padding,
      required this.notifier});
  final RestaurantMenuItem item;
  final EdgeInsets padding;
  final RestaurantMenu notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editedItem = ref.watch(RestaurantMenuProvider()).value!.editedItem!;
    return AlertDialog(
        title: Column(
          children: [
            Text(
              item.id == -1 ? "Dodaj pozycję" : "Edytuj pozycję",
              style: headerStyle,
            ),
            headerDivider
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(6.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: item.name,
                validator: (input) {
                  if (input == "" || input == null) return null;
                  return input.length > 3
                      ? null
                      : "Długość nazwy musi być większa lub równa 3";
                },
                onChanged: notifier.updateEditedItemName,
                decoration:
                    defaultDecoration(icon: Icons.title, labelText: 'Nazwa')),
            const SizedBox(height: 12.0),
            TextFormField(
                initialValue: item.description,
                maxLines: 3,
                onChanged: notifier.updateEditedItemDescription,
                decoration: defaultDecoration(
                    icon: Icons.description, labelText: 'Opis')),
            const SizedBox(height: 12.0),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialValue:
                  item.price.toStringAsFixed(2).replaceFirst('.', ','),
              validator: (input) {
                if (input == "" || input == null) return null;
                return RestaurantMenuItem.priceValidate(input) == null
                    ? "Liczba musi być w formacie 1234,56"
                    : null;
              },
              onChanged: notifier.updateEditedItemPrice,
              decoration: defaultDecoration(
                  labelText: "Cena (zł)", icon: Icons.attach_money),
            ),
            const SizedBox(height: 12.0),
            DropdownMenu<RestaurantMenuItemType>(
                leadingIcon: const Icon(Icons.list),
                requestFocusOnTap: false,
                initialSelection: item.status,
                enableFilter: false,
                enableSearch: false,
                label: const Text("Status"),
                onSelected: notifier.updateEditedItemStatus,
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: [
                  for (final type in RestaurantMenuItemType.values)
                    DropdownMenuEntry(
                        value: type, label: type.label, leadingIcon: type.icon)
                ]),
            const SizedBox(height: 12.0),
            const Text(
              "Zdjęcie",
              style: listStyle,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                MenuUploadPhotoTile(
                    photoUrl: editedItem.photoUrl,
                    showUpload: () => uploadRestaurantFile(
                        context, notifier.uploadEditedItemPhoto, 1.0),
                    isMain: false),
                const SizedBox(width: 24),
                if (editedItem.photoUrl.isNotEmpty)
                  IconButton(
                      tooltip: "Usuń zdjęcie",
                      onPressed: notifier.setEmptyEditedItemPhoto,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 32,
                      ))
              ],
            )
          ]),
        ),
        insetPadding: padding,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.save),
              color: Colors.indigo,
              tooltip: "Zapisz zmiany",
              onPressed: editedItem.id == -2
                  ? null
                  : () async {
                      final result = await notifier.saveEditedItem();
                      if (result) {
                        Navigator.pop(context, "Zapisz zmiany");
                      }
                    }),
          if (item.id != -1)
            IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: "Usuń pozycję",
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => DefaultDialog(
                        title: "Usuń pozycję",
                        text: "Czy napewno usunąć pozycję?",
                        onConfirm: () async {
                          Navigator.pop(context, 'Tak');
                        }),
                  );
                  if (confirm == 'Tak') {
                    final result = await notifier.deleteItem(item.id);
                    if (result) {
                      Navigator.pop(context, "Usuń pozycję");
                    }
                  }
                }),
          IconButton(
              icon: const Icon(Icons.cancel),
              color: primaryColor,
              tooltip: "Anuluj",
              onPressed: editedItem.id == -2
                  ? null
                  : () {
                      if (item.id == -1 && editedItem.photoUrl.isNotEmpty) {
                        notifier.removeEditedItemPhoto();
                      }
                      Navigator.pop(context, 'Anuluj');
                    })
        ]);
  }
}
