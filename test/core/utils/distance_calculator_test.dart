import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/app_constants.dart';
import 'package:mapid/core/utils/distance_calculator.dart';

void main() {
  group('DistanceCalculator Tests (Haversine Formula)', () {
    const yogyakartaLat = AppConstants.yogyakartaLatitude; // -7.7956
    const yogyakartaLon = AppConstants.yogyakartaLongitude; // 110.3695

    test('should return 0.0 meters when calculating distance between identical coordinates', () {
      final distance = DistanceCalculator.calculateDistance(
        startLatitude: yogyakartaLat,
        startLongitude: yogyakartaLon,
        endLatitude: yogyakartaLat,
        endLongitude: yogyakartaLon,
      );

      expect(distance, 0.0);
    });

    test('should calculate distance within DIY region (<50 km)', () {
      // Malioboro intersection coordinate
      const malioboroLat = -7.7928;
      const malioboroLon = 110.3658;

      final distance = DistanceCalculator.calculateDistance(
        startLatitude: yogyakartaLat,
        startLongitude: yogyakartaLon,
        endLatitude: malioboroLat,
        endLongitude: malioboroLon,
      );

      // Distance between Yogyakarta center and Malioboro is ~510 meters
      expect(distance, greaterThan(450.0));
      expect(distance, lessThan(650.0));
      expect(distance, lessThan(AppConstants.yogyakartaThresholdMeters));
    });

    test('should calculate distance to Kaliurang (<50 km)', () {
      // Kaliurang landmark coordinate (~23 km north)
      const kaliurangLat = -7.5950;
      const kaliurangLon = 110.4285;

      final distance = DistanceCalculator.calculateDistance(
        startLatitude: yogyakartaLat,
        startLongitude: yogyakartaLon,
        endLatitude: kaliurangLat,
        endLongitude: kaliurangLon,
      );

      expect(distance, greaterThan(20000.0));
      expect(distance, lessThan(26000.0));
      expect(distance, lessThan(AppConstants.yogyakartaThresholdMeters));
    });

    test('should calculate distance to Jakarta (>50 km)', () {
      // Monas, Jakarta coordinate (~430 km northwest)
      const jakartaLat = -6.2088;
      const jakartaLon = 106.8456;

      final distance = DistanceCalculator.calculateDistance(
        startLatitude: yogyakartaLat,
        startLongitude: yogyakartaLon,
        endLatitude: jakartaLat,
        endLongitude: jakartaLon,
      );

      expect(distance, greaterThan(400000.0));
      expect(distance, greaterThan(AppConstants.yogyakartaThresholdMeters));
    });

    test('should calculate distance to Mountain View, California (>50 km)', () {
      // Googleplex, Mountain View, California coordinate (~14,000 km away)
      const mountainViewLat = 37.4220;
      const mountainViewLon = -122.0841;

      final distance = DistanceCalculator.calculateDistance(
        startLatitude: yogyakartaLat,
        startLongitude: yogyakartaLon,
        endLatitude: mountainViewLat,
        endLongitude: mountainViewLon,
      );

      expect(distance, greaterThan(13000000.0));
      expect(distance, greaterThan(AppConstants.yogyakartaThresholdMeters));
    });

    test('isOutsideYogyakartaThreshold returns false for nearby coordinates', () {
      const malioboroLat = -7.7928;
      const malioboroLon = 110.3658;

      final isOutside = DistanceCalculator.isOutsideYogyakartaThreshold(
        latitude: malioboroLat,
        longitude: malioboroLon,
      );

      expect(isOutside, isFalse);
    });

    test('isOutsideYogyakartaThreshold returns true for coordinates exceeding 50 km', () {
      const mountainViewLat = 37.4220;
      const mountainViewLon = -122.0841;

      final isOutside = DistanceCalculator.isOutsideYogyakartaThreshold(
        latitude: mountainViewLat,
        longitude: mountainViewLon,
      );

      expect(isOutside, isTrue);
    });

    test('isOutsideYogyakartaThreshold supports custom threshold override', () {
      const kaliurangLat = -7.5950;
      const kaliurangLon = 110.4285;

      // Distance to Kaliurang is ~23 km. Threshold 20 km -> isOutside = true
      final isOutsideStrict = DistanceCalculator.isOutsideYogyakartaThreshold(
        latitude: kaliurangLat,
        longitude: kaliurangLon,
        thresholdMeters: 20000.0,
      );
      expect(isOutsideStrict, isTrue);

      // Threshold 30 km -> isOutside = false
      final isOutsidePermissive = DistanceCalculator.isOutsideYogyakartaThreshold(
        latitude: kaliurangLat,
        longitude: kaliurangLon,
        thresholdMeters: 30000.0,
      );
      expect(isOutsidePermissive, isFalse);
    });
  });
}
