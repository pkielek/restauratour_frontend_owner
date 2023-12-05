import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/basic_providers.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
class Jwt with _$Jwt {
  const Jwt._();

  factory Jwt(String jwtToken) = _Jwt;

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
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  get getUsername => null;

  @override
  Jwt build() {
    final storedToken = ref.read(
            sharedPreferencesProvider.select((p) => p.getString("token"))) ??
        "";
    ref.listenSelf((prev, curr) {
      ref.read(sharedPreferencesProvider).setString("token", curr.jwtToken);
    });
    return Jwt(storedToken);
  }

  void logOut() {
    state = Jwt("");
  }

  void login(String jwtToken) {
    state = Jwt(jwtToken);
  }
}

enum AuthenticationState { logged, loggedOut }

class AuthState {
  final Ref ref;
  AuthenticationState? current;
  AuthState(this.ref);

  void updateState(Map<String, dynamic> jwt) {}

  Stream<AuthenticationState> authCheck() async* {
    final Jwt jwt = ref.watch(authProvider);
    while (true) {
      final now = DateTime.now().toUtc().secondsSinceEpoch;
      if (current != null) {
        await Future.delayed(const Duration(seconds: 5));
      }
      if (jwt.jwtToken.isEmpty) {
        current = AuthenticationState.loggedOut;
      } else {
        final expireTime = jwt.getExpirationTime();
        if (expireTime > now) {
          current = AuthenticationState.logged;
        } else {
          ref.read(authProvider.notifier).logOut();
          ref.read(inactivityLogoutProvider.notifier).state = true;
          current = AuthenticationState.loggedOut;
        }
      }
      yield current!;
    }
  }
}
final authStateProvider = StreamProvider<AuthenticationState>((ref) => AuthState(ref).authCheck());


final inactivityLogoutProvider = StateProvider<bool>((ref) => false);

