import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;
  
  List<BottomNavigationBarItem> get _buildBottomNavBarItems => [
        const BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Карта',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Обращения',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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