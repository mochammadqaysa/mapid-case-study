/// Pure domain entity representing user's geographic coordinates (REQ-005, CON-001).
class UserLocationEntity {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const UserLocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocationEntity &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'UserLocationEntity(lat: $latitude, lon: $longitude, acc: $accuracy)';
}
