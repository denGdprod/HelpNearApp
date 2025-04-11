// lib/core/app/auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/features/auth/verify_email_screen.dart';
import 'package:helpnear_app/features/map/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Ошибка аутентификации')),
          );
        }

        final user = snapshot.data;
        
        if (user == null) {
          return const HomeScreen(); // Или LoginScreen, если нужен гостевой доступ
        }

        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        return const HomeScreen();
      },
    );
  }
}