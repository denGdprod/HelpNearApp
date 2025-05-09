import 'package:helpnear_app/data/models/moscow_location.dart';
import 'package:helpnear_app/core/app/app_location.dart';
import 'package:geolocator/geolocator.dart';

class LocationService implements AppLocation {
  final defLocation = const MoscowLocation();

  @override
  Future<AppLatLong> getCurrentLocation() async {
  return Geolocator.getCurrentPosition().then((value) {
    return AppLatLong(lat: value.latitude, long: value.longitude);
  }).catchError(
    (_) => defLocation,
  );
  }
  @override
  Future<bool> requestPermission() {
    return Geolocator.requestPermission()
     .then((value) =>
         value == LocationPermission.always ||
         value == LocationPermission.whileInUse)
     .catchError((_) => false);
  }
  @override
  Future<bool> checkPermission() {
  return Geolocator.checkPermission()
     .then((value) =>
         value == LocationPermission.always ||
         value == LocationPermission.whileInUse)
     .catchError((_) => false);
  }
}
