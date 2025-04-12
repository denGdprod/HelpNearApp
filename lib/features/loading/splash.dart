import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';  // Подключаем AuthStateNotifier

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateNotifier>(
      builder: (context, authState, child) {
        // Если загрузка продолжается, показываем экран загрузки
        if (authState.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Когда isLoading == false, переходите на основной экран через маршруты
        return const SizedBox.shrink(); // Пустой виджет, так как маршруты уже настроены в MyApp
      },
    );
  }
}

// Виджет для анимации логотипа
// class AnimatedLogo extends StatefulWidget {
//   const AnimatedLogo({super.key});

//   @override
//   _AnimatedLogoState createState() => _AnimatedLogoState();
// }

// class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     // Создаем анимацию с контроллером
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);  // Анимация будет повторяться

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: Image.asset(
//         'assets/logo.png',  // Путь к вашему логотипу
//         width: 100,
//         height: 100,
//       ),
//     );
//   }
// }
