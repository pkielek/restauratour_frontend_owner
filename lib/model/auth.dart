import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'basic_providers.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
class Jwt with _$Jwt {
  const Jwt._();

  factory Jwt(String jwtToken, [@Default(false) bool loggedOut]) = _Jwt;

  Map<String, dynamic>? parseJwt() {
    final parts = jwtToken.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = _decodeBase64(parts[1]);
    if (payload == null) {
      return null;
    }

    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }

    return payloadMap;
  }

  String? _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        return null;
    }

    return utf8.decode(base64Url.decode(output));
  }

  Set<String> getScopes() {
    final parsedJwt = parseJwt();
    if (parsedJwt == null) return {};
    return (parsedJwt['scopes'] as String).split(' ').toSet();
  }

  String getUsername() {
    final parsedJwt = parseJwt();
    if (parsedJwt == null) return "";
    return parsedJwt['name'] as String;
  }

  int getExpirationTime() {
    final parsedJwt = parseJwt();
    if (parsedJwt == null) return 0;
    return parsedJwt['exp'] as int;
  }

  bool get isLogged => jwtToken.isNotEmpty;

  AuthType get authType {
    if(getScopes().contains('owner:basic')) {
      return AuthType.owner;
    }
    if(getScopes().contains('worker:basic')) {
      return AuthType.worker;
    }
    return AuthType.user;
  }

  bool containsAuthType(AuthType type) {
    return getScopes().contains('${type.name}:basic');
  }
}

enum AuthType {
  owner,worker,user;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {

  @override
  Stream<Jwt> build() async* {
    while(true) {
      ref.listenSelf((previous, current) => ref.read(sharedPreferencesProvider).setString("token",current.value!.jwtToken));
      if(state.value != null && state.value!.getExpirationTime() <= DateTime.now().toUtc().secondsSinceEpoch) {
        logOut();
      }
      final storedToken = ref.read(
          sharedPreferencesProvider.select((p) => p.getString("token"))) ??
      "";
      yield Jwt(storedToken, state.value?.loggedOut ?? false);
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  void logOut() {
    state = AsyncData(Jwt("", true));
  }

  void login(String jwtToken) {
    state = AsyncData(Jwt(jwtToken, false));
  }
}

final inactivityLogoutProvider = StateProvider<bool>((ref) => false);

