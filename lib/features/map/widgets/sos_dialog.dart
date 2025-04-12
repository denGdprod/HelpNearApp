import 'package:flutter/material.dart';

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Заглушка',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
