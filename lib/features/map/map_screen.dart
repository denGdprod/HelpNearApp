import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:helpnear_app/core/app/services/LocationService.dart';
import 'package:helpnear_app/data/models/moscow_location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();
  final List<MapObject> _mapObjects = [];
  Point? _currentPosition;
  CameraPosition? _cameraPosition;

  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
      ),
      body: Stack(
        children: [
        YandexMap(
          onMapCreated: (controller) {
            if (!mapControllerCompleter.isCompleted) {
              mapControllerCompleter.complete(controller);
            }
          },
          mapObjects: _mapObjects,
          onCameraPositionChanged: (CameraPosition position, CameraUpdateReason reason, bool finished) {
            if (!finished) {
              if (_currentPosition != null) {
                setState(() {
                  _currentPosition = null;
                });
              }
            } else {
              _onCameraMoved(position);
            }
          },
        ),
          // Маркер по центру
        const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: 45),
            child: Icon(Icons.location_on, size: 90, color: Colors.red),
            ),
          ),
          // Блок с координатами
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Текущие координаты:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentPosition != null
                        ? 'Широта: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                          'Долгота: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        : 'Определение...\n',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCameraMoved(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _cameraPosition = position;
    });
  }

  Future<void> _initPermission() async {
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    await _moveToCurrentLocation(location);
  }

  Future<void> _moveToCurrentLocation(AppLatLong appLatLong) async {
    final controller = await mapControllerCompleter.future;
    final point = Point(latitude: appLatLong.lat, longitude: appLatLong.long);

    await controller.moveCamera(
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 16),
      ),
    );

    setState(() {
      _currentPosition = point;
    });
  }
}
//   void _showSOSDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Экстренный вызов'),
//         content: const Text('Вы уверены, что хотите отправить сигнал SOS?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Отмена'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Сигнал SOS отправлен!')),
//               );
//             },
//             child: const Text('Отправить', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }

  // class _MapScreenState extends State<MapScreen> {
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Карта'),
  //       centerTitle: true,
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.my_location),
  //           onPressed: () {
  //             // Заглушка для кнопки "Мое местоположение"
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Определение местоположения...')),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //     body: Stack(
  //       children: [
  //         // Заглушка карты (можно заменить на реальную карту)
  //         Container(
  //           color: Colors.grey[200],
  //           child: Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Icon(Icons.map_outlined, size: 100, color: Colors.blue),
  //                 const SizedBox(height: 16),
  //                 Text(
  //                   'Карта будет здесь',
  //                   style: Theme.of(context).textTheme.headlineSmall,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),

  //         // Кнопка SOS (можно переместить в нужное место)
  //         Positioned(
  //           bottom: 20,
  //           right: 20,
  //           child: FloatingActionButton.large(
  //             onPressed: () {
  //               _showSOSDialog(context);
  //             },
  //             backgroundColor: Colors.red,
  //             child: const Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.emergency, color: Colors.white),
  //                 Text('SOS', style: TextStyle(color: Colors.white)),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }