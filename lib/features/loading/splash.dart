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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashTimer();
    });
  }

  Future<void> _startSplashTimer() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      
      // Более безопасный способ доступа к Provider
      final authNotifier = Provider.of<AuthStateNotifier>(
        context,
        listen: false,
      );
      authNotifier.finishSplash();
    } catch (e) {
      debugPrint('Ошибка в SplashScreen: $e');
      if (!mounted) return;
      // Можно добавить обработку ошибки (например, переход на экран ошибки)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Загрузка...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}