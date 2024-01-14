import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';
import 'package:restaurant_helper/widgets/menu/menu_item_edit_dialog.dart';
import 'package:utils/utils.dart';

class MenuItemTile extends HookConsumerWidget {
  const MenuItemTile(
      {super.key,
      required this.item,
      required this.parentSize,
      this.editable = false});
  final Size parentSize;
  final RestaurantMenuItem item;
  final bool editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: item.isPending ? Colors.grey.shade300 : null,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.photoUrl.isNotEmpty)
            AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(item.photoUrl, fit: BoxFit.fill)),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: RichText(
                    text:
                        TextSpan(text: item.name, style: listStyle, children: [
                  if(editable)
                    WidgetSpan(child: item.status.icon),
                  TextSpan(
                      text: '\n${item.description}',
                      style:
                          const TextStyle(fontWeight: FontWeight.w400, fontSize: 15))
                ])),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${item.price.toStringAsFixed(2)} zł',
                  style: listStyle,
                ),
              )
            ],
          ))
        ],
      ),
    );
    if (editable) {
      return InkWell(
          child: tile,
          onTap: () {
            ref.read(RestaurantMenuProvider().notifier).setEditedItem(item);
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => MenuItemEditDialog(
                  item: ref.read(RestaurantMenuProvider()).value!.editedItem!,
                  notifier: ref.read(RestaurantMenuProvider().notifier),
                  padding: EdgeInsets.symmetric(
                      horizontal: 0.2 * 0.8 * parentSize.width,
                      vertical: parentSize.height * 0.05)),
            );
          });
    }
    return tile;
  }
}
