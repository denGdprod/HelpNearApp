import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/core/app/app_router.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:yandex_maps_mapkit_lite/init.dart' as init;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Future(() => init.initMapkit(
    apiKey: '4bbfd5f6-fa17-4f24-8e99-e3ef164f9d92'
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthStateNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthStateNotifier>(context);
    final router = createRouter(auth);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routerConfig: router,
    );
  }
}