import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper/routes.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utils/utils.dart';


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
      theme: themeData,
      routerDelegate: RoutemasterDelegate(
          routesBuilder: (context) => ref.watch(authProvider).when(
                data: (data) => data.isLogged
                    ? routes
                    : loggedOutRoute,
                error: (error, stackTrace) => loggedOutRoute,
                loading: () => loadingRoute,
              )),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
