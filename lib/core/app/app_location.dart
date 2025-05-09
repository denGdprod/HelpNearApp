import 'package:helpnear_app/data/models/moscow_location.dart';

abstract class AppLocation {
 Future<AppLatLong> getCurrentLocation();

 Future<bool> requestPermission();

 Future<bool> checkPermission();
}