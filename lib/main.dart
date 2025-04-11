import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/core/app/app_router.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //запуск firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routerConfig: appRouter, // Передаем конфиг роутера
    );
  }
}