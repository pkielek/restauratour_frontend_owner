import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_menu.dart';
import 'package:utils/utils.dart';

class MenuCategoryTile extends ConsumerWidget {
  const MenuCategoryTile(
      {super.key,
      required this.notifier,
      required this.category,
      required this.isSelected});
  final RestaurantMenu notifier;
  final RestaurantMenuCategory category;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Focus(
                onFocusChange: (value) =>
                    value ? notifier.selectCategory(category.id) : null,
                child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\n"))
                  ],
                  onTap: () => notifier.selectCategory(category.id),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  minLines: 1,
                  maxLines: null,
                  validator: (value) => value == null
                      ? null
                      : (value.length < 4 ? 'Minimalna długość: 4' : null),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    isDense: true,
                    errorText: "",
                    errorBorder: InputBorder.none,
                    errorStyle: TextStyle(height: 0.1, fontSize: 8.0),
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                  ),
                  initialValue: category.name,
                  onChanged: (value) =>
                      notifier.updateCategoryName(category.id, value),
                  style: category.isPending
                      ? listStyleInactive
                      : (isSelected ? listStyleSelected : listStyle),
                ),
              ),
            ),
            if (category.timer != null && category.restartTimer)
              Expanded(
                  flex:2,
                  child: TweenAnimationBuilder(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 3),
                      builder: (__, value, _) =>
                          CircularProgressIndicator(value: value)))
            else
              const Expanded(flex:2,child:SizedBox()),
                          
            Expanded(
                flex: 2,
                child: IconButton(
                  tooltip:
                      "W${category.isVisible ? "y" : ""}łącz widoczność kategorii",
                  icon: Icon(category.isVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  color: category.isVisible ? Colors.black : primaryColor,
                  onPressed: () => notifier.switchVisibility(category.id),
                )),
            Expanded(
                flex: 2,
                child: IconButton(
                  tooltip: "Usuń kategorię",
                  icon: const Icon(Icons.delete),
                  color: Colors.grey,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => DefaultDialog(
                        title: "Usuń kategorię",
                        text:
                            "Usunięcie kategorii spowoduje usunięcie wszystkich jej produktów! Czy kontynuować?",
                        onConfirm: () {
                          notifier.deleteCategory(category.id);
                          Navigator.pop(context, 'Tak');
                        }),
                  ),
                )),
            const Expanded(child: SizedBox())
          ],
        ));
  }
}
