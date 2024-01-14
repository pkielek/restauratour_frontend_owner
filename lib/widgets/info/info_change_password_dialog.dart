import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/restaurant_info.dart';
import 'package:utils/utils.dart';

class InfoChangePasswordDialog extends ConsumerWidget {
  const InfoChangePasswordDialog(
      {super.key, required this.password, required this.confirmPassword});
  final String password;
  final String confirmPassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text("Zmień hasło"),
      content: IntrinsicHeight(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(children: [
            TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                initialValue: password,
                validator: (input) {
                  if (input == "" || input == null) return null;
                  return validatePassword(input).join('\n');
                },
                onChanged: ref.read(InfoProvider().notifier).updateNewPassword,
                decoration: defaultDecoration(
                    icon: Icons.password, labelText: "Nowe hasło")),
            const Padding(padding: EdgeInsets.only(top: 16)),
            TextFormField(
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: confirmPassword,
                validator: (input) {
                  if (input == "" || input == null) return null;
                  return ref
                          .read(InfoProvider())
                          .value!
                          .areNewPasswordsIdentical
                      ? null
                      : "Hasła muszą być identyczne";
                },
                onChanged:
                    ref.read(InfoProvider().notifier).updateConfirmNewPassword,
                decoration: defaultDecoration(
                    icon: Icons.password, labelText: "Potwierdź hasło"))
          ]),
        ),
      ),
      actions: <Widget>[
        IconButton(
            icon: const Icon(Icons.save),
            color: Colors.indigo,
            tooltip: "Zapisz hasło",
            onPressed: () async {
              if(await ref.read(InfoProvider().notifier).saveNewPassword()) Navigator.pop(context,'Zapisz hasło');

            }),
        IconButton(
            icon: const Icon(Icons.cancel),
            color: primaryColor,
            tooltip: "Anuluj",
            onPressed: () {
              ref.read(InfoProvider().notifier).cancelPasswordUpdate();
              Navigator.pop(context, 'Anuluj');
            })
      ],
    );
  }
}
