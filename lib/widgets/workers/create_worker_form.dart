import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/model/create_worker.dart';
import 'package:restaurant_helper/model/worker.dart';
import 'package:restaurant_helper/screens/login/login_view.dart';
import 'package:restaurant_helper/widgets/login/email_field.dart';
import 'package:restaurant_helper/widgets/workers/worker_data_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../model/auth.dart';
import '../../widgets/helper/styles.dart';
import '../../widgets/login/password_field.dart';
import 'worker_email_field.dart';

class CreateWorkerForm extends HookConsumerWidget {
  final RoundedLoadingButtonController _submitController =
      RoundedLoadingButtonController();

  CreateWorkerForm({super.key});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(createWorkerStateProvider.notifier).state;
    final _emailController = useTextEditingController();
    final _firstNameController = useTextEditingController();
    final _surnameController = useTextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(createWorkerStateProvider.notifier).updateControllers({
      "email": _emailController,
      "firstName": _firstNameController,
      "surname": _surnameController
    }));

    Size size = MediaQuery.of(context).size;  
    return Expanded(
        child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top:10.0,left:10, right:10),
              child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(children: [
                    WorkerEmailField(
                        controller:_emailController,
                        onSubmit: () => ref
                            .read(createWorkerStateProvider.notifier)
                            .sendForm(_submitController)),
                    const SizedBox(height: 15),
                    WorkerDataField(
                        controller:_firstNameController,
                        onSubmit: () => ref
                            .read(createWorkerStateProvider.notifier)
                            .sendForm(_submitController),
                        fieldName: "firstName",
                        fieldShownName: "Imię"),
                    const SizedBox(height: 15),
                    WorkerDataField(
                        controller:_surnameController,
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
