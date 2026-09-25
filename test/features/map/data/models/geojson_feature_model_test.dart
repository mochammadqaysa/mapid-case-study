import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/features/map/data/models/geojson_feature_model.dart';

void main() {
  group('GeoJsonFeatureModel Tests', () {
    const fullGeoJsonFixture = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [110.3672, -7.8003]
          },
          'properties': {
            'NAMA': 'Keraton Yogyakarta',
            'ALAMAT':
                'Jl. Rotowijayan Blok No. 1, Panembahan, Kecamatan Kraton, Kota Yogyakarta',
            'KECAMATAN': 'Kraton',
            'WAKTU': '2024-09-24 08:00:00'
          }
        }
      ]
    };

    test('should parse valid GeoJSON FeatureCollection into LayerResponseModel', () {
      final model = LayerResponseModel.fromJson(fullGeoJsonFixture);

      expect(model.type, 'FeatureCollection');
      expect(model.features.length, 1);

      final feature = model.features.first;
      expect(feature.type, 'Feature');
      expect(feature.geometry.longitude, 110.3672);
      expect(feature.geometry.latitude, -7.8003);
      expect(feature.properties.name, 'Keraton Yogyakarta');
      expect(feature.properties.district, 'Kraton');
      expect(feature.properties.recordTime, '2024-09-24 08:00:00');
    });

    test('should defensively fallback null or empty property values to "-" (GUD-003)', () {
      final incompleteJson = {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [110.3695, -7.7956]
        },
        'properties': {
          'NAMA': null,
          'ALAMAT': '   ',
          'KECAMATAN': '',
          // WAKTU is omitted completely
        }
      };

      final feature = GeoJsonFeatureModel.fromJson(incompleteJson);

      expect(feature.properties.name, '-');
      expect(feature.properties.address, '-');
      expect(feature.properties.district, '-');
      expect(feature.properties.recordTime, '-');
    });

    test('should handle empty coordinates safely', () {
      final emptyCoordsJson = {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': []
        },
        'properties': {}
      };

      final feature = GeoJsonFeatureModel.fromJson(emptyCoordsJson);

      expect(feature.geometry.longitude, 0.0);
      expect(feature.geometry.latitude, 0.0);
    });

    test('should map GeoJsonFeatureModel to MapFeatureEntity correctly', () {
      final model = LayerResponseModel.fromJson(fullGeoJsonFixture);
      final entity = model.features.first.toEntity();

      expect(entity.id, 'Keraton Yogyakarta');
      expect(entity.name, 'Keraton Yogyakarta');
      expect(entity.district, 'Kraton');
      expect(entity.latitude, -7.8003);
      expect(entity.longitude, 110.3672);
    });

    test('should serialize back to JSON accurately', () {
      final model = LayerResponseModel.fromJson(fullGeoJsonFixture);
      final jsonMap = model.toJson();

      expect(jsonMap['type'], 'FeatureCollection');
      expect((jsonMap['features'] as List).length, 1);
    });
  });
}
