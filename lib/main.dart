import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/core/app/auth_wrapper.dart';
import 'package:helpnear_app/features/map/home_screen.dart';
import 'package:helpnear_app/features/profile/account_screen.dart';
import 'package:helpnear_app/features/auth/login_screan.dart';
import 'package:helpnear_app/features/auth/signup_screen.dart';
import 'package:helpnear_app/features/auth/reset_password_screen.dart';
import 'package:helpnear_app/features/auth/verify_email_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //запуск firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
      },
      initialRoute: '/',
    );
  }
}