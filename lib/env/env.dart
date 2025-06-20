import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPKIT_API_KEY')
  static const String mapKitApiKey = _Env.mapKitApiKey;
}