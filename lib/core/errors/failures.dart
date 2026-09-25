/// Base class for domain-level failure representations.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => '$runtimeType: $message';
}

/// Represents failure from remote geoserver or REST API.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, [this.statusCode]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerFailure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, statusCode);
}

/// Represents network connectivity failures (offline, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Represents GPS / location permission denials.
class LocationPermissionFailure extends Failure {
  final bool isPermanentlyDenied;
  const LocationPermissionFailure(
    super.message, {
    this.isPermanentlyDenied = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPermissionFailure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          isPermanentlyDenied == other.isPermanentlyDenied;

  @override
  int get hashCode => Object.hash(message, isPermanentlyDenied);
}

/// Represents device location service being disabled at system level.
class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure(super.message);
}
