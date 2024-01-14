import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:restaurant_helper/model/restaurant_info.dart';
import 'package:restaurant_helper/screens/base_view.dart';
import 'package:restaurant_helper/widgets/info/info_change_password_dialog.dart';
import 'package:restaurant_helper/widgets/info/restaurant_hour_text_field.dart';
import 'package:restaurant_helper/widgets/info/restaurant_info_map.dart';
import 'package:restaurant_helper/widgets/shared/email_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:utils/utils.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

class InfoView extends ConsumerWidget {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(InfoProvider());
    ref.listen(
        InfoProvider().select((value) => value.when(
            data: (data) => data.isChanged,
            error: (_, __) => false,
            loading: () => false)), (previous, next) {
      ref.read(unsavedChangesProvider.notifier).state = next;
    });
    final submitController = RoundedLoadingButtonController();
    double widthPadded = MediaQuery.of(context).size.width * 0.8;
    return BaseView(
        screen: data.when(
            data: (data) {
              final number = PhoneNumber.fromCompleteNumber(
                  completeNumber: data.phoneNumber);
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: widthPadded,
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.name, style: boldBig),
                                  const Padding(
                                      padding: EdgeInsets.only(bottom: 8)),
                                  Text(data.toFullAddress,
                                      style: headerLightStyle),
                                  const Padding(
                                      padding: EdgeInsets.only(bottom: 2)),
                                  RichText(
                                      text: TextSpan(
                                          text: "NIP",
                                          style: listStyle,
                                          children: [
                                        TextSpan(
                                            text: ':${data.nip}',
                                            style: listLightStyle)
                                      ])),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                  ),
                                  SizedBox(
                                    width: 0.75 * 0.5 * widthPadded,
                                    child: EmailField(
                                      initialValue: data.email,
                                      onChanged: ref
                                          .read(InfoProvider().notifier)
                                          .updateEmail,
                                      labelText: "Kontakt mailowy",
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                  ),
                                  SizedBox(
                                      width: 0.75 * 0.5 * widthPadded,
                                      child: IntlPhoneField(
                                          initialValue: number.number,
                                          onChanged: ref
                                              .read(InfoProvider().notifier)
                                              .updatePhoneNumber,
                                          pickerDialogStyle: PickerDialogStyle(
                                              width: 0.7 * widthPadded,
                                              backgroundColor: Colors.white),
                                          searchText: "Wyszukaj swój kraj",
                                          invalidNumberMessage:
                                              "Niepoprawny numer telefonu",
                                          initialCountryCode:
                                              number.countryISOCode,
                                          languageCode: 'PL',
                                          decoration: defaultDecoration(
                                              icon: Icons.phone,
                                              labelText: "Numer telefonu"))),
                                  const Padding(
                                      padding: EdgeInsets.only(bottom: 32.0)),
                                  const Row(
                                    children: [
                                      SizedBox(
                                        width: 455,
                                        child: Text("Godziny otwarcia",
                                            style: boldBig),
                                      ),
                                      Tooltip(
                                          message:
                                              "Restauracja zamknięta w dany dzień",
                                          child: Icon(Icons.close)),
                                      SizedBox(width: 17),
                                      Tooltip(
                                          message:
                                              "Godziny otwarcia w ten dzień są tymczasowe",
                                          child: Icon(Icons.schedule))
                                    ],
                                  ),
                                  for (final (_, weekName)
                                      in data.openingHours.entries.indexed)
                                    SizedBox(
                                      width: 0.85 * 0.5 * widthPadded,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 160,
                                            child: Text(
                                                getWeekdayName(weekName.key),
                                                style: listStyle),
                                          ),
                                          RestaurantHourTextField(
                                              day: weekName.key,
                                              data: weekName.value,
                                              isCloseTime: false),
                                          const SizedBox(
                                              width: 30,
                                              child: Text("-",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 32))),
                                          RestaurantHourTextField(
                                              day: weekName.key,
                                              data: weekName.value,
                                              isCloseTime: true),
                                          const SizedBox(width: 10),
                                          Checkbox(
                                              value: weekName.value.closed,
                                              onChanged: (_) => ref
                                                  .read(InfoProvider().notifier)
                                                  .toggleClosed(weekName.key)),
                                          const SizedBox(width: 10),
                                          Checkbox(
                                              value: weekName.value.temporary,
                                              onChanged: (_) => ref
                                                  .read(InfoProvider().notifier)
                                                  .toggleTemporary(
                                                      weekName.key)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final flag in data.flags)
                                  CheckboxListTile(
                                    isThreeLine: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    value: flag.setting,
                                    onChanged: (_) => ref
                                        .read(InfoProvider().notifier)
                                        .toggleCheckbox(flag.id),
                                    title: Text(flag.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(flag.description ?? ""),
                                  ),
                                const Padding(padding: EdgeInsets.only(top: 8)),
                                FilledButton(
                                    onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              InfoChangePasswordDialog(
                                                  password: data.newPassword,
                                                  confirmPassword:
                                                      data.confirmNewPassword),
                                        ),
                                    child: const Text("Zmień hasło")),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                ),
                                RestaurantInfoMap(width: widthPadded * 0.48)
                              ],
                            ))
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 16)),
                        RoundedLoadingButton(
                          color: primaryColor,
                          successIcon: Icons.done,
                          failedIcon: Icons.close,
                          resetAfterDuration: true,
                          resetDuration: const Duration(seconds: 2),
                          width: 2000,
                          controller: submitController,
                          onPressed: ref.read(InfoProvider().notifier).saveData,
                          child: const Text('Zapisz zmiany',
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            error: (error, stackTrace) => Center(
                    child: Text(
                  error.toString(),
                  style: boldBig,
                )),
            loading: () =>
                const Loading("Trwa ładowanie danych restauracji...")));
  }
}
