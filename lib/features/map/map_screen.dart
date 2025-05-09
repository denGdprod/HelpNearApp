import 'package:flutter/material.dart';
import 'dart:async';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:helpnear_app/core/app/services/LocationService.dart';
import 'package:helpnear_app/data/models/moscow_location.dart';
import 'package:permission_handler/permission_handler.dart';

void requestLocationPermission() async {
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapControllerCompleter = Completer<YandexMapController>();
  final List<MapObject> _mapObjects = [];
  bool _isMapLoaded = false;
  
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
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: 45), // Adjust based on the image size
            child: Image.asset(
              'assets/images/location-pin512px.png',
              width: 90,
              height: 90,
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
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
    await controller.moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 16,
        ),
      ),
    );
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