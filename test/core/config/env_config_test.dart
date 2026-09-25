import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/app_constants.dart';
import 'package:mapid/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('should return configured environment values when present', () {
      final mockEnv = {
        'MAPID_API_KEY': 'test_api_key_123',
        'MAPID_LAYER_ID': 'layer_456',
        'MAPID_PROJECT_ID': 'project_789',
        'MAPID_GEOSERVER_URL': 'https://custom.geoserver.io/get_layer',
        'MAPID_BASEMAP_STYLE_URL': 'https://custom.tiles.org/style.json',
      };

      final envConfig = EnvConfig(mockEnv);

      expect(envConfig.mapidApiKey, 'test_api_key_123');
      expect(envConfig.mapidLayerId, 'layer_456');
      expect(envConfig.mapidProjectId, 'project_789');
      expect(envConfig.geoServerBaseUrl, 'https://custom.geoserver.io/get_layer');
      expect(envConfig.basemapStyleUrl, 'https://custom.tiles.org/style.json');
    });

    test('should fallback to defaults when optional keys are absent', () {
      final mockEnv = <String, String>{};

      final envConfig = EnvConfig(mockEnv);

      expect(envConfig.mapidApiKey, '');
      expect(envConfig.mapidLayerId, '');
      expect(envConfig.mapidProjectId, '');
      expect(envConfig.geoServerBaseUrl, AppConstants.defaultGeoserverUrl);
      expect(envConfig.basemapStyleUrl, AppConstants.defaultBasemapStyleUrl);
    });

    test('should trim whitespace from environment values', () {
      final mockEnv = {
        'MAPID_API_KEY': '  trimmed_key  ',
        'MAPID_LAYER_ID': '  layer_abc  ',
        'MAPID_PROJECT_ID': '  project_xyz  ',
        'MAPID_GEOSERVER_URL': '  https://custom.geoserver.io  ',
        'MAPID_BASEMAP_STYLE_URL': '  https://custom.style.org  ',
      };

      final envConfig = EnvConfig(mockEnv);

      expect(envConfig.mapidApiKey, 'trimmed_key');
      expect(envConfig.mapidLayerId, 'layer_abc');
      expect(envConfig.mapidProjectId, 'project_xyz');
      expect(envConfig.geoServerBaseUrl, 'https://custom.geoserver.io');
      expect(envConfig.basemapStyleUrl, 'https://custom.style.org');
    });
  });
}

