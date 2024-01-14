import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:restaurant_helper/widgets/menu/menu_category_tile.dart';
import 'package:restaurant_helper/widgets/menu/menu_item_edit_dialog.dart';
import 'package:restaurant_helper/widgets/menu/menu_item_tile.dart';
import 'package:restaurant_helper/widgets/menu/menu_upload_photo_tile.dart';
import 'package:utils/utils.dart';

class MenuView extends ConsumerWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widthPadded = MediaQuery.of(context).size.width * 0.8;
    final provider = ref.watch(RestaurantMenuProvider());
    final notifier = ref.read(RestaurantMenuProvider().notifier);
    return BaseView(
        screen: provider.when(
            data: (menu) {
              return Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Center(
                    child: SizedBox(
                  width: widthPadded,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Kategorie",
                                style: headerStyle,
                                textAlign: TextAlign.center,
                              ),
                              headerLeftDivider,
                              Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: MenuUploadPhotoTile(
                                      photoUrl: menu.photoUrl,
                                      showUpload: () => uploadRestaurantFile(
                                          context,
                                          notifier.uploadRestaurantImage),
                                      isMain: true)),
                              ReorderableListView(
                                buildDefaultDragHandles: !menu.menu
                                    .any((element) => element.isPending),
                                shrinkWrap: true,
                                onReorder: notifier.categoryReorder,
                                footer: FilledButton(
                                    onPressed: notifier.addCategory,
                                    child: const Text(
                                      "Dodaj kategorię",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          height: 2.5),
                                    )),
                                children: [
                                  for (final category in menu.menu)
                                    MenuCategoryTile(
                                        key: Key('cat:${category.id}'),
                                        notifier: notifier,
                                        category: category,
                                        isSelected: menu.selectedCategory ==
                                            category.id)
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Text(
                                    menu.selectedCategory == 0
                                        ? ""
                                        : menu.menu
                                            .firstWhere((element) =>
                                                element.id ==
                                                menu.selectedCategory)
                                            .name,
                                    style: headerStyle),
                              ),
                              headerRightDivider,
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: SingleChildScrollView(
                                  child: ReorderableGridView.count(
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio: 2.5,
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      onReorder: notifier.itemReorder,
                                      dragEnabled: !menu.menu
                                          .firstWhere((element) =>
                                              element.id ==
                                              menu.selectedCategory)
                                          .items
                                          .any((element) => element.isPending),
                                      footer: [
                                        OutlinedButton(
                                          style: ButtonStyle(
                                              side:
                                                  const MaterialStatePropertyAll(
                                                      BorderSide(
                                                          color: Colors.black,
                                                          width: 2.0)),
                                              shape: MaterialStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)))),
                                          child: const Icon(
                                            Icons.add,
                                            color: primaryColor,
                                            size: 96,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(RestaurantMenuProvider()
                                                    .notifier)
                                                .setEditedItem(RestaurantMenuItem(
                                                    id: -1,
                                                    name: "",
                                                    description: "",
                                                    price: 0.00,
                                                    order: -1,
                                                    status:
                                                        RestaurantMenuItemType
                                                            .inactive,
                                                    photoUrl: ""));
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => MenuItemEditDialog(
                                                  item: RestaurantMenuItem(
                                                      id: -1,
                                                      name: "",
                                                      description: "",
                                                      price: 0.00,
                                                      order: -1,
                                                      status:
                                                          RestaurantMenuItemType
                                                              .inactive,
                                                      photoUrl: ""),
                                                  notifier: notifier,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          0.2 * widthPadded,
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.05)),
                                            );
                                          },
                                        )
                                      ],
                                      children: [
                                        for (final item in menu.menu
                                            .firstWhere((element) =>
                                                element.id ==
                                                menu.selectedCategory)
                                            .items)
                                          MenuItemTile(
                                              parentSize:
                                                  MediaQuery.of(context).size,
                                              key: Key('item:${item.id}'),
                                              item: item,
                                              editable: !menu.menu
                                                  .firstWhere((element) =>
                                                      element.id ==
                                                      menu.selectedCategory)
                                                  .items
                                                  .any((element) =>
                                                      element.isPending))
                                      ]),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                )),
              );
            },
            error: (error, stackTrace) => Center(
                    child: Text(
                  error.toString(),
                  style: boldBig,
                )),
            loading: () => const Loading("Trwa ładowanie menu restauracji..")));
  }
}
