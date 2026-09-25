/// Application-wide constants and configuration defaults for MAPID Mobile GIS.
abstract final class AppConstants {
  // Yogyakarta Center Anchor Coordinates (REQ-001, ADR-0001)
  static const double yogyakartaLatitude = -7.7956;
  static const double yogyakartaLongitude = 110.3695;

  // Camera Zoom Boundaries (CON-003)
  static const double initialZoom = 12.0;
  static const double minZoom = 4.0;
  static const double maxZoom = 18.0;

  // Spatial & Viewport Thresholds (REQ-006, REQ-004)
  static const double yogyakartaThresholdMeters = 50000.0; // 50 km boundary
  static const double popupCameraOffsetRatio = 0.35; // 35% bottom viewport padding

  // Default Network Endpoints (SEC-001 fallback)
  static const String defaultGeoserverUrl =
      'https://geoserver.mapid.io/layers_new/get_layer';
  static const String defaultBasemapStyleUrl =
      'https://tiles.openfreemap.org/styles/liberty';

  // Defensive Null Safety (GUD-003)
  static const String fallbackPlaceholder = '-';

  // MapLibre Layer & Source Identifiers (REQ-003, REQ-005, REQ-004)
  static const String geoJsonSourceId = 'geomapid-features-source';
  static const String circleLayerId = 'geomapid-features-circle-layer';
  static const String selectedFeatureSourceId = 'selected-feature-source';
  static const String selectedFeatureCircleLayerId = 'selected-feature-circle-layer';
  static const String selectedFeatureHaloLayerId = 'selected-feature-halo-layer';
  static const String userLocationSourceId = 'user-location-source';
  static const String userLocationCircleLayerId = 'user-location-circle-layer';
  static const String userLocationHaloLayerId = 'user-location-halo-layer';

  // Antislop & UI Constraints (GUD-001)
  static const double minTouchTargetSize = 48.0;
}
