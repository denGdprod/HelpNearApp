// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:yandex_mapkit/yandex_mapkit.dart';
// import 'package:flutter/material.dart';

// class HelpRequestsService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Загрузить поток документов из коллекции help_requests
//   Stream<List<MapObject>> getHelpRequestMarkers() {
//     return _firestore.collection('help_requests').snapshots().map((snapshot) {
//       List<MapObject> markers = [];

//       for (final doc in snapshot.docs) {
//         final data = doc.data();

//         final latitude = data['latitude'];
//         final longitude = data['longitude'];

//         if (latitude != null && longitude != null) {
//           final point = Point(latitude: latitude, longitude: longitude);

//           // Создаём PlacemarkMapObject с кастомной иконкой
//           final marker = PlacemarkMapObject(
//             mapId: MapObjectId(doc.id),
//             point: point,
//             opacity: 0.9,
//             icon: PlacemarkIcon.single(
//               IconStyle(
//                 image: BitmapDescriptor.fromAssetImage('assets/images/marker.png'),
//                 scale: 1.0,
//               ),
//             ),
//             // Опционально: добавим тап-обработчик или информацию
//           );

//           markers.add(marker);
//         }
//       }

//       return markers;
//     });
//   }
// }
