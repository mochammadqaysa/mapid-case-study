/// Pure domain entity representing a Feature Point on the GIS map (REQ-002, CON-001).
class MapFeatureEntity {
  final String id;
  final String name;
  final String address;
  final String district;
  final String recordTime;
  final double latitude;
  final double longitude;

  const MapFeatureEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.recordTime,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFeatureEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address &&
          district == other.district &&
          recordTime == other.recordTime &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        address,
        district,
        recordTime,
        latitude,
        longitude,
      );

  @override
  String toString() =>
      'MapFeatureEntity(name: $name, district: $district, lat: $latitude, lon: $longitude)';
}
