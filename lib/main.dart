import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/providers/basic_providers.dart';
import 'package:restaurant_helper/routes.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'model/auth.dart';

Future<void> main() async {
  final prefs = await SharedPreferences.getInstance();
  await dotenv.load();
  runApp(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Restaurant Helper',
      theme: ThemeData(
          primarySwatch: primarySwatch,
          colorScheme: ColorScheme.fromSeed(seedColor: primarySwatch),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Montserrat',
          inputDecorationTheme: InputDecorationTheme(
              prefixIconColor: Colors.black,
              suffixIconColor: Colors.black,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.black))),
          scrollbarTheme: const ScrollbarThemeData(
              thumbColor: MaterialStatePropertyAll(Colors.grey),
              thickness: MaterialStatePropertyAll(5),
              thumbVisibility: MaterialStatePropertyAll(true))),
      routerDelegate: RoutemasterDelegate(
          routesBuilder: (context) => ref.watch(authStateProvider).when(
                data: (data) => data == AuthenticationState.logged
                    ? routes
                    : loggedOutRoute,
                error: (error, stackTrace) => loggedOutRoute,
                loading: () => loadingRoute,
              )),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
