import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_constants.dart';

/// Contract for strongly-typed environment variables (SEC-001).
abstract class IEnvConfig {
  String get mapidApiKey;
  String get mapidLayerId;
  String get mapidProjectId;
  String get geoServerBaseUrl;
  String get basemapStyleUrl;
}

/// Implementation of [IEnvConfig] backed by [flutter_dotenv] with compile-time fallback (SEC-001).
class EnvConfig implements IEnvConfig {
  final Map<String, String> _env;

  /// Creates an [EnvConfig] instance.
  /// If [env] is not provided, defaults to [dotenv.env].
  EnvConfig([Map<String, String>? env]) : _env = env ?? dotenv.env;

  @override
  String get mapidApiKey =>
      _resolve('MAPID_API_KEY', const String.fromEnvironment('MAPID_API_KEY'));

  @override
  String get mapidLayerId =>
      _resolve('MAPID_LAYER_ID', const String.fromEnvironment('MAPID_LAYER_ID'));

  @override
  String get mapidProjectId =>
      _resolve('MAPID_PROJECT_ID', const String.fromEnvironment('MAPID_PROJECT_ID'));

  @override
  String get geoServerBaseUrl {
    final val = _resolve(
      'MAPID_GEOSERVER_URL',
      const String.fromEnvironment('MAPID_GEOSERVER_URL'),
    );
    return val.isNotEmpty ? val : AppConstants.defaultGeoserverUrl;
  }

  @override
  String get basemapStyleUrl {
    final val = _resolve(
      'MAPID_BASEMAP_STYLE_URL',
      const String.fromEnvironment('MAPID_BASEMAP_STYLE_URL'),
    );
    return val.isNotEmpty ? val : AppConstants.defaultBasemapStyleUrl;
  }

  String _resolve(String key, String compileTimeFallback) {
    final val = _env[key];
    if (val != null && val.trim().isNotEmpty) {
      return val.trim();
    }
    return compileTimeFallback.trim();
  }
}

