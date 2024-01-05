import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper/model/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'worker.freezed.dart';
part 'worker.g.dart';

enum AccountStatus {
  @JsonValue("Aktywny") active,
  @JsonValue("Nieaktywny") disabled,
  @JsonValue("Usunięty") deleted,
  @JsonValue("Zablokowany") blocked;

  
  String get toLabel {
    switch(this) {
      case active:
        return "Aktywny";
      case disabled:
        return 'Niekatywny';
      case deleted:
        return 'Usunięty';
      case blocked:
        return 'Zablokowany';
    }
  }

  Color get color {
    switch(this) {
      case active:
        return Colors.green;
      case disabled:
      case deleted:
        return Colors.grey;
      case blocked:
        return Colors.red;
    }
  }
}


@freezed
class Worker with _$Worker {
  factory Worker({
    required int id,
    required String firstName,
    required String surname,
    required String email,
    required AccountStatus status,
  }) = _Worker;

  factory Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);
}

@riverpod
class WorkerList extends _$WorkerList {
  @override
  Future<List<Worker>> build() async {
    final token = ref.read(authProvider).value!;
    try {
      final response = await Dio().post('${dotenv.env['API_URL']!}workers-list',
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      return (response.data as List<dynamic>)
          .map((e) => Worker.fromJson(e))
          .toList();
    } on DioException catch (e) {
        if (e.response != null) {
          Map responseBody = e.response!.data;
          fluttertoastDefault(responseBody['detail'],true);
        } else {
          fluttertoastDefault("Coś poszło nie tak przy wczytywaniu listy kelnerów. Spróbuj ponownie później",true);
        }
    }
    return [];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> workerAction(int id, String link) async {
    List<String> availableActions = ['remove-worker','disable-worker','enable-worker','resend-worker-activation-link'];
    if(!availableActions.contains(link)) {
      fluttertoastDefault('Błąd aplikacji',true);
    } else {
      final token = ref.read(authProvider).value!;
      try {
        final response = await Dio().post(
            '${dotenv.env['API_URL']!}$link',
            data: {"worker_id": id},
            options:
                Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
        refresh();
        fluttertoastDefault(response.data['message']);
      } on DioException catch (e) {
        if (e.response != null) {
          Map responseBody = e.response!.data;
          fluttertoastDefault(responseBody['detail'],true);
        } else {
          fluttertoastDefault("Coś poszło nie tak. Spróbuj ponownie później",true);
        }
      }
    }
  }
}
