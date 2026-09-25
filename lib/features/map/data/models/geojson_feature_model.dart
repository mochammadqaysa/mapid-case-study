import '../../../../core/config/app_constants.dart';
import '../../domain/entities/map_feature_entity.dart';

/// Top-level response model representing GeoJSON FeatureCollection (REQ-002, GUD-003).
class LayerResponseModel {
  final String type;
  final List<GeoJsonFeatureModel> features;

  const LayerResponseModel({
    required this.type,
    required this.features,
  });

  factory LayerResponseModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'] as List<dynamic>? ?? [];
    return LayerResponseModel(
      type: json['type'] as String? ?? 'FeatureCollection',
      features: rawFeatures
          .whereType<Map>()
          .map((f) => GeoJsonFeatureModel.fromJson(Map<String, dynamic>.from(f)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'features': features.map((f) => f.toJson()).toList(),
    };
  }
}

/// DTO representing an individual GeoJSON Feature.
class GeoJsonFeatureModel {
  final String type;
  final GeoJsonGeometryModel geometry;
  final GeoJsonPropertiesModel properties;

  const GeoJsonFeatureModel({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory GeoJsonFeatureModel.fromJson(Map<String, dynamic> json) {
    final rawGeometry = json['geometry'];
    final rawProperties = json['properties'];

    return GeoJsonFeatureModel(
      type: json['type'] as String? ?? 'Feature',
      geometry: GeoJsonGeometryModel.fromJson(
        rawGeometry is Map ? Map<String, dynamic>.from(rawGeometry) : const {},
      ),
      properties: GeoJsonPropertiesModel.fromJson(
        rawProperties is Map ? Map<String, dynamic>.from(rawProperties) : const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': properties.name,
      'geometry': geometry.toJson(),
      'properties': properties.toJson(),
    };
  }

  MapFeatureEntity toEntity() {
    return MapFeatureEntity(
      id: properties.name,
      name: properties.name,
      address: properties.address,
      district: properties.district,
      recordTime: properties.recordTime,
      latitude: geometry.latitude,
      longitude: geometry.longitude,
    );
  }
}

/// DTO representing Point geometry with geographic coordinates.
class GeoJsonGeometryModel {
  final String type;
  final double longitude;
  final double latitude;

  const GeoJsonGeometryModel({
    required this.type,
    required this.longitude,
    required this.latitude,
  });

  factory GeoJsonGeometryModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final lon = (coords.isNotEmpty && coords[0] is num)
        ? (coords[0] as num).toDouble()
        : 0.0;
    final lat = (coords.length > 1 && coords[1] is num)
        ? (coords[1] as num).toDouble()
        : 0.0;

    return GeoJsonGeometryModel(
      type: json['type'] as String? ?? 'Point',
      longitude: lon,
      latitude: lat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': [longitude, latitude],
    };
  }
}

/// DTO representing business properties with defensive null fallback (GUD-003).
class GeoJsonPropertiesModel {
  final String name;
  final String address;
  final String district;
  final String recordTime;

  const GeoJsonPropertiesModel({
    required this.name,
    required this.address,
    required this.district,
    required this.recordTime,
  });

  factory GeoJsonPropertiesModel.fromJson(Map<String, dynamic> json) {
    String sanitize(dynamic value) {
      if (value == null) return AppConstants.fallbackPlaceholder;
      final str = value.toString().trim();
      return str.isNotEmpty ? str : AppConstants.fallbackPlaceholder;
    }

    return GeoJsonPropertiesModel(
      name: sanitize(json['NAMA']),
      address: sanitize(json['ALAMAT']),
      district: sanitize(json['KECAMATAN']),
      recordTime: sanitize(json['WAKTU']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NAMA': name,
      'ALAMAT': address,
      'KECAMATAN': district,
      'WAKTU': recordTime,
    };
  }
}
