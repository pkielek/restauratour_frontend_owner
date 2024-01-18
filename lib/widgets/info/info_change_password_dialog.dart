import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';

class InfoChangePasswordDialog extends ConsumerWidget {
  const InfoChangePasswordDialog(
      {super.key, required this.type});
  final AuthType type;

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
                initialValue: ref.watch(RegisterProvider(type)).password,
                validator: (input) {
                  if (input == "" || input == null) return null;
                  return validatePassword(input).join('\n');
                },
                onChanged: ref.read(RegisterProvider(type).notifier).updatePassword,
                decoration: defaultDecoration(
                    icon: Icons.password, labelText: "Nowe hasło")),
            const Padding(padding: EdgeInsets.only(top: 16)),
            TextFormField(
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: ref.watch(RegisterProvider(type)).confirmPassword,
                validator: (input) {
                  if (input == "" || input == null) return null;
                  return ref.watch(RegisterProvider(type)).password == ref.watch(RegisterProvider(type)).confirmPassword
                      ? null
                      : "Hasła muszą być identyczne";
                },
                onChanged:
                    ref.read(RegisterProvider(type).notifier).updateConfirmPassword,
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
              if(await ref.read(RegisterProvider(type).notifier).register()) Navigator.pop(context,'Zapisz hasło');

            }),
        IconButton(
            icon: const Icon(Icons.cancel),
            color: primaryColor,
            tooltip: "Anuluj",
            onPressed: () {
              ref.read(RegisterProvider(type).notifier).cancelPasswordUpdate();
              Navigator.pop(context, 'Anuluj');
            })
      ],
    );
  }
}
