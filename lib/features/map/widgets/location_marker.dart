// location_marker.dart
import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationMarker {
  final String markerId;
  final Point point;
  final String iconAsset;

  LocationMarker({
    required this.markerId,
    required this.point,
    required this.iconAsset,
  });

  // Method to create a PlacemarkMapObject with custom icon from an asset
  Future<PlacemarkMapObject> createLocationMarker() async {
    final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
      iconAsset, // Asset path
    );

    PlacemarkIconStyle iconStyle = PlacemarkIconStyle(
      image: icon,
      scale: 1.0,
      isFlat: true,
      isVisible: true,
    );

    return PlacemarkMapObject(
      mapId: MapObjectId(markerId),
      point: point,
      icon: PlacemarkIcon.single(iconStyle),
      opacity: 1.0,
      zIndex: 1.0,
      isVisible: true,
      consumeTapEvents: true,
    );
  }
}
