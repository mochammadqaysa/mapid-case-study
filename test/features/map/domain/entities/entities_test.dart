import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/features/map/domain/entities/map_feature_entity.dart';
import 'package:mapid/features/map/domain/entities/user_location_entity.dart';

void main() {
  group('MapFeatureEntity Tests', () {
    const tFeature1 = MapFeatureEntity(
      id: 'poi-1',
      name: 'Keraton Yogyakarta',
      address: 'Jl. Rotowijayan Blok No. 1',
      district: 'Kraton',
      recordTime: '2026-09-24 10:00:00',
      latitude: -7.8053,
      longitude: 110.3642,
    );

    const tFeature2 = MapFeatureEntity(
      id: 'poi-1',
      name: 'Keraton Yogyakarta',
      address: 'Jl. Rotowijayan Blok No. 1',
      district: 'Kraton',
      recordTime: '2026-09-24 10:00:00',
      latitude: -7.8053,
      longitude: 110.3642,
    );

    const tFeatureDifferent = MapFeatureEntity(
      id: 'poi-2',
      name: 'Tugu Pal Putih',
      address: 'Jl. Jend. Sudirman',
      district: 'Gondokusuman',
      recordTime: '2026-09-24 11:00:00',
      latitude: -7.7829,
      longitude: 110.3670,
    );

    test('should support value equality', () {
      expect(tFeature1, equals(tFeature2));
      expect(tFeature1.hashCode, equals(tFeature2.hashCode));
      expect(tFeature1, isNot(equals(tFeatureDifferent)));
    });

    test('should produce readable toString output', () {
      expect(
        tFeature1.toString(),
        contains('Keraton Yogyakarta'),
      );
      expect(
        tFeature1.toString(),
        contains('Kraton'),
      );
    });
  });

  group('UserLocationEntity Tests', () {
    final tTime = DateTime(2026, 9, 24, 12, 0, 0);

    final tLocation1 = UserLocationEntity(
      latitude: -7.7956,
      longitude: 110.3695,
      accuracy: 5.0,
      timestamp: tTime,
    );

    final tLocation2 = UserLocationEntity(
      latitude: -7.7956,
      longitude: 110.3695,
      accuracy: 10.0,
      timestamp: tTime,
    );

    final tLocationDifferent = UserLocationEntity(
      latitude: -7.8000,
      longitude: 110.3700,
      accuracy: 5.0,
      timestamp: tTime,
    );

    test('should support value equality based on coordinates', () {
      expect(tLocation1, equals(tLocation2));
      expect(tLocation1.hashCode, equals(tLocation2.hashCode));
      expect(tLocation1, isNot(equals(tLocationDifferent)));
    });

    test('should produce readable toString output', () {
      expect(
        tLocation1.toString(),
        contains('-7.7956'),
      );
      expect(
        tLocation1.toString(),
        contains('110.3695'),
      );
    });
  });
}
