/// Data-layer exception thrown when remote API returns non-200 responses.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Data-layer exception thrown on network connection drop or DNS failure.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Data-layer exception thrown when location permission is rejected.
class LocationPermissionException implements Exception {
  final String message;
  final bool isPermanentlyDenied;
  const LocationPermissionException(
    this.message, {
    this.isPermanentlyDenied = false,
  });

  @override
  String toString() =>
      'LocationPermissionException: $message (permanent: $isPermanentlyDenied)';
}

/// Data-layer exception thrown when hardware GPS is disabled.
class LocationServiceDisabledException implements Exception {
  final String message;
  const LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}
