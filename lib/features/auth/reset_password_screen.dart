import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/core/utils/snack_bar.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailTextInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTextInputController.dispose();
    super.dispose();
  }

Future<void> resetPassword() async {
  final isValid = formKey.currentState!.validate();
  if (!isValid) return;

  final navigator = GoRouter.of(context);

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailTextInputController.text.trim(),
    );
  } on FirebaseAuthException catch (e) {
    print(e.code);

    // Используем switch для обработки ошибок
    switch (e.code) {
      case 'user-not-found':
        SnackBarService.showSnackBar(context, 'Такой email незарегистрирован!', true);
        break;
      case 'invalid-email':
        SnackBarService.showSnackBar(context, 'Некорректный email.', true);
        break;
      default:
        SnackBarService.showSnackBar(context, 'Неизвестная ошибка. Попробуйте позже.', true);
    }
    return; // Возвращаемся после обработки ошибки, чтобы не продолжать выполнение метода
  }

  // Если сброс пароля прошел успешно, показываем сообщение об успехе
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Сброс пароля осуществлен. Проверьте почту'),
      backgroundColor: Colors.green,
    ),
  );

  // Перенаправляем пользователя на экран home
  navigator.go('/home');
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Сброс пароля'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                controller: emailTextInputController,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Введите правильный Email'
                        : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Введите Email',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: resetPassword,
                child: const Center(child: Text('Сбросить пароль')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
