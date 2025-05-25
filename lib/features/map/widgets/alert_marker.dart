import 'package:yandex_mapkit/yandex_mapkit.dart';

class AlertMarker {
  final String markerId;
  final Point point;
  final String iconAsset;

  AlertMarker({
    required this.markerId,
    required this.point,
    required this.iconAsset,
  });

  /// Создаёт `PlacemarkMapObject` с кастомной иконкой из ассетов
  Future<PlacemarkMapObject> createAlertMarker() async {
    final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
      iconAsset,
    );

    final iconStyle = PlacemarkIconStyle(
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
      zIndex: 10.0,
      isVisible: true,
      consumeTapEvents: true,
    );
  }
}