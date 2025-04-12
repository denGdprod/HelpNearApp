import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {

     final router = GoRouter.of(context);

    await FirebaseAuth.instance.signOut();

    router.goNamed('signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Аккаунт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Open shopping cart',
            onPressed: () => signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ваш Email: ${user?.email}'),
            TextButton(
              onPressed: () => signOut(),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}
