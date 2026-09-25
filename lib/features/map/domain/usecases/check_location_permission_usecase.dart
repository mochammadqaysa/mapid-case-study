import '../repositories/map_repository.dart';

/// Domain use case for checking whether location permissions are granted (REQ-005, SEC-002).
class CheckLocationPermissionUseCase {
  final MapRepository repository;

  const CheckLocationPermissionUseCase(this.repository);

  Future<bool> call() {
    return repository.checkLocationPermission();
  }
}
