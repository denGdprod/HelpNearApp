import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/core/app/app_router.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:helpnear_app/features/loading/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //запуск firebase
  await Firebase.initializeApp();
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
    // Показываем заглушку, пока Firebase Auth загружается
    if (auth.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        );
    }
    final router = createRouter(auth);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routerConfig: router,
    );
  }
}