import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:restaurant_helper/widgets/menu/menu_category_tile.dart';
import 'package:restaurant_helper/widgets/menu/menu_item_edit_dialog.dart';
import 'package:utils/utils.dart';
import 'package:image_picker/image_picker.dart';

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
                          padding: EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Kategorie",
                                style: headerStyle,
                                textAlign: TextAlign.center,
                              ),
                              headerLeftDivider,
                              Tooltip(
                                message: "Dodaj zdjęcie główne",
                                child: AspectRatio(
                                  aspectRatio: 2.0,
                                  child: OutlinedButton(
                                    style: const ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                            BorderSide(
                                                color: Colors.black,
                                                width: 3.0)),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder())),
                                    child: const Icon(
                                      Icons.photo,
                                      color: primaryColor,
                                      size: 96,
                                    ),
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(source: ImageSource.gallery);
                                      print(await image!.readAsBytes());
                                    },
                                  ),
                                ),
                              ),
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
                                        key: Key('${category.id}'),
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
                              headerDivider,
                              Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: ReorderableGridView.count(
                                    childAspectRatio: 2.5,
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    onReorder: (_, __) => null,
                                    footer: [
                                      OutlinedButton(
                                        style: const ButtonStyle(
                                            side: MaterialStatePropertyAll(
                                                BorderSide(
                                                    color: Colors.black,
                                                    width: 3.0)),
                                            shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder())),
                                        child: const Icon(
                                          Icons.add,
                                          color: primaryColor,
                                          size: 96,
                                        ),
                                        onPressed: () => showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) =>
                                              MenuItemEditDialog(
                                                  onConfirm: () => null,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          0.4 * widthPadded,
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.15)),
                                        ),
                                      )
                                    ],
                                    children: [
                                      for (final item in menu.menu
                                          .firstWhere((element) =>
                                              element.id ==
                                              menu.selectedCategory)
                                          .items)
                                        Container(
                                          key: Key('${item.id}'),
                                        )
                                    ]),
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
