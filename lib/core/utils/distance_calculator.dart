import 'dart:math';
import '../config/app_constants.dart';

/// Pure Dart utility for spatial distance calculation using the Haversine trigonometric formula (REQ-006, ASSUMPTION-002).
abstract final class DistanceCalculator {
  /// Mean Earth radius in meters according to WGS-84.
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates the great-circle distance between two geographic coordinates in meters.
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final double dLat = _toRadians(endLatitude - startLatitude);
    final double dLon = _toRadians(endLongitude - startLongitude);

    final double lat1Rad = _toRadians(startLatitude);
    final double lat2Rad = _toRadians(endLatitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Evaluates whether a given coordinate exceeds the distance threshold from Yogyakarta center anchor (ADR-0001).
  static bool isOutsideYogyakartaThreshold({
    required double latitude,
    required double longitude,
    double thresholdMeters = AppConstants.yogyakartaThresholdMeters,
  }) {
    final double distance = calculateDistance(
      startLatitude: AppConstants.yogyakartaLatitude,
      startLongitude: AppConstants.yogyakartaLongitude,
      endLatitude: latitude,
      endLongitude: longitude,
    );
    return distance > thresholdMeters;
  }

  static double _toRadians(double degrees) => degrees * (pi / 180.0);
}
