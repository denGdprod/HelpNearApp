import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;
  
  List<BottomNavigationBarItem> get _buildBottomNavBarItems => [
        const BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Заметки',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Любимые',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          IconButton(
            onPressed: () {
              // context.go('/settings');
            },
            icon: const Icon(
              Icons.settings_input_antenna,
              color: Color.fromARGB(255, 91, 144, 243),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: _buildBottomNavBarItems,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}