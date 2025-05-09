// location_marker.dart
import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationMarkerAura {
  final String markerId;
  final Point point;
  final String iconAsset;

  LocationMarkerAura({
    required this.markerId,
    required this.point,
    required this.iconAsset,
  });

  // Method to create a PlacemarkMapObject with custom icon from an asset
  Future<PlacemarkMapObject> createLocationMarkerAura() async {
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
      opacity: 0.3,
      zIndex: 1.0,
      isVisible: true,
      consumeTapEvents: true,
    );
  }
}