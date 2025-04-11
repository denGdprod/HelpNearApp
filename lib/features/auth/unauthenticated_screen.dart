import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnauthenticatedScreen extends StatefulWidget {
  const UnauthenticatedScreen({super.key});

  @override
  State<UnauthenticatedScreen> createState() => _UnauthenticatedScreenState();
}
  class _UnauthenticatedScreenState extends State<UnauthenticatedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Неавторизованный доступ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Для работы в системе необходима авторизация',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Кнопка регистрации
            ElevatedButton(
                onPressed: () => context.goNamed('signup'),
                child: const Center(child: Text('Регистрация')),
            ),
            const SizedBox(height: 20),
            // Вопрос и кнопка входа
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Уже есть аккаунт? '),
                TextButton(
                onPressed: () => context.goNamed('login'),
                child: const Text('Войти'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
