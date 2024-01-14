import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/model/create_worker.dart';
import 'package:restaurant_helper/widgets/shared/email_field.dart';
import 'package:restaurant_helper/widgets/workers/worker_data_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:utils/utils.dart';

class CreateWorkerForm extends HookConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  CreateWorkerForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(createWorkerStateProvider);
    final emailController = useTextEditingController();
    final firstNameController = useTextEditingController();
    final surnameController = useTextEditingController();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(createWorkerStateProvider.notifier).updateControllers({
              "email": emailController,
              "firstName": firstNameController,
              "surname": surnameController
            }));

    return Expanded(
        child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
              child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: [
                    EmailField(
                        controller: emailController,
                        onChanged: ref
                            .read(createWorkerStateProvider.notifier)
                            .updateEmail,
                        onSubmit: () => ref
                            .read(createWorkerStateProvider.notifier)
                            .sendForm(_submitController)),
                    const SizedBox(height: 15),
                    WorkerDataField(
                        controller: firstNameController,
                        onSubmit: () => ref
                            .read(createWorkerStateProvider.notifier)
                            .sendForm(_submitController),
                        fieldName: "firstName",
                        fieldShownName: "Imię"),
                    const SizedBox(height: 15),
                    WorkerDataField(
                        controller: surnameController,
                        onSubmit: () => ref
                            .read(createWorkerStateProvider.notifier)
                            .sendForm(_submitController),
                        fieldName: "surname",
                        fieldShownName: "Nazwisko"),
                    const SizedBox(height: 15),
                    RoundedLoadingButton(
                      color: primaryColor,
                      successIcon: Icons.done,
                      failedIcon: Icons.close,
                      resetDuration: const Duration(seconds: 2),
                      resetAfterDuration: true,
                      width: 2000,
                      controller: _submitController,
                      onPressed: () => ref
                          .read(createWorkerStateProvider.notifier)
                          .sendForm(_submitController),
                      child: const Text('Utwórz kelnera',
                          style: TextStyle(color: Colors.white)),
                    )
                  ])),
            )));
  }
}
