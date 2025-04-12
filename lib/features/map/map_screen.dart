import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Заглушка для кнопки "Мое местоположение"
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Определение местоположения...')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Заглушка карты (можно заменить на реальную карту)
          Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 100, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Карта будет здесь',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),

          // Кнопка SOS (можно переместить в нужное место)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.large(
              onPressed: () {
                _showSOSDialog(context);
              },
              backgroundColor: Colors.red,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emergency, color: Colors.white),
                  Text('SOS', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Экстренный вызов'),
        content: const Text('Вы уверены, что хотите отправить сигнал SOS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Сигнал SOS отправлен!')),
              );
            },
            child: const Text('Отправить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}