import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpnear_app/core/utils/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      isEmailVerified = refreshedUser?.emailVerified ?? false;

      if (isEmailVerified) {
        timer?.cancel();
        if (!mounted) return;
        final auth = context.read<AuthStateNotifier>();
        await auth.refreshUser();
        if (mounted) context.go('/email_verified');
      }
    } catch (e) {
      timer?.cancel();
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        if (mounted) context.go('/login');
      } else {
        if (mounted) {
          SnackBarService.showSnackBar(
            context,
            'Ошибка: $e',
            true,
          );
        }
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          'Ошибка отправки: $e',
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Верификация Email адреса'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Письмо с подтверждением было отправлено на вашу электронную почту.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  icon: const Icon(Icons.email),
                  label: const Text('Повторно отправить'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    timer?.cancel();
                    await FirebaseAuth.instance.currentUser?.delete();
                    if (mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text(
                    'Отменить',
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
