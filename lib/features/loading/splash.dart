import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // После задержки, мы уведомляем модель о завершении загрузки
      context.read<AuthStateNotifier>().finishSplash();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

