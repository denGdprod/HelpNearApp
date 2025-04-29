import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpnear_app/core/utils/snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:helpnear_app/features/auth/CastomLoadingDialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  bool isHiddenPassword1 = true;
  bool isHiddenPassword2 = true;
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  TextEditingController passwordTextRepeatInputController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();
    passwordTextRepeatInputController.dispose();

    super.dispose();
  }

  void togglePasswordView1() {
    setState(() {
      isHiddenPassword1 = !isHiddenPassword1;
    });
  }
  void togglePasswordView2() {
    setState(() {
      isHiddenPassword2 = !isHiddenPassword2;
    });
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пустым';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Пароль должен содержать хотя бы одну цифру';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Пароль должен содержать хотя бы одну заглавную букву';
    }
    return null;
  }
  Future<void> signUp() async {

    if (!formKey.currentState!.validate()) return;
    showDialog(
    context: context,
    barrierDismissible: false, // Чтобы пользователь не мог закрыть диалог
    builder: (context) => const CustomLoadingDialog(),
    );
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Этот Email уже используется. Пожалуйста, используйте другой.';
          break;
        case 'weak-password':
          errorMessage = 'Пароль слишком слабый. Используйте более сложный пароль.';
          break;
        case 'invalid-email':
          errorMessage = 'Некорректный Email. Пожалуйста, проверьте введенные данные.';
          break;
        default:
          errorMessage = 'Произошла ошибка: ${e.message ?? "Неизвестная ошибка"}';
      }
    SnackBarService.showSnackBar(context, errorMessage, true);
  } catch (e) {
    // Обрабатываем все другие ошибки
    if (mounted) Navigator.pop(context);
    SnackBarService.showSnackBar(
      context,
      'Произошла непредвиденная ошибка. Пожалуйста, попробуйте позже.',
      true,
    );
    debugPrint('Ошибка регистрации: $e');
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Зарегистрироваться'),
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
              TextFormField(
                autocorrect: false,
                controller: passwordTextInputController,
                obscureText: isHiddenPassword1,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validatePassword,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Введите пароль',
                  suffix: InkWell(
                    onTap: togglePasswordView1,
                    child: Icon(
                      isHiddenPassword1
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                autocorrect: false,
                controller: passwordTextRepeatInputController,
                obscureText: isHiddenPassword2,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value != passwordTextInputController.text) {
                    return 'Пароли не совпадают';
                    }
                  return _validatePassword(value); // Проверяем валидность + совпадение`
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Введите пароль еще раз',
                  suffix: InkWell(
                    onTap: togglePasswordView2,
                    child: Icon(
                      isHiddenPassword2
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: signUp,
                child: const Center(child: Text('Регистрация')),
              ),
              const SizedBox(height: 30),
              TextButton(
              onPressed: () => context.goNamed('login'),
                child: const Text(
                  'Войти',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
