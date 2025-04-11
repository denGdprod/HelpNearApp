import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          IconButton(
            onPressed: () {
              if ((user == null)) {
                context.go('/login');
              } else {
                context.go('/account');
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? const Color.fromARGB(255, 91, 144, 243) : const Color.fromARGB(255, 255, 255, 255) ,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: (user == null)
              ? const Text("Контент для НЕ зарегистрированных в системе")
              : const Text('Контент для ЗАРЕГИСТРИРОВАННЫХ в системе'),
          //child: Text('Контент для НЕ зарегистрированных в системе'),
        ),
      ),
    );
  }
}