import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_location_entity.dart';

/// Contract for acquiring device GPS position and handling permissions (REQ-005, SEC-002, ADR-0001).
abstract class ILocationDataSource {
  /// Evaluates whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Checks current runtime location permission status.
  Future<bool> checkPermission();

  /// Requests runtime location permission from the operating system.
  Future<bool> requestPermission();

  /// Acquires current GPS coordinates on demand.
  Future<UserLocationEntity> getCurrentLocation();

  /// Opens application settings to allow manual permission granting.
  Future<bool> openAppSettings();
}

/// Implementation of [ILocationDataSource] utilizing [geo.GeolocatorPlatform].
class LocationDataSource implements ILocationDataSource {
  final geo.GeolocatorPlatform platform;

  LocationDataSource({geo.GeolocatorPlatform? platform})
      : platform = platform ?? geo.GeolocatorPlatform.instance;

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await platform.isLocationServiceEnabled();
  }

  @override
  Future<bool> checkPermission() async {
    final permission = await platform.checkPermission();
    return permission == geo.LocationPermission.always ||
        permission == geo.LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    final permission = await platform.requestPermission();
    return permission == geo.LocationPermission.always ||
        permission == geo.LocationPermission.whileInUse;
  }

  @override
  Future<UserLocationEntity> getCurrentLocation() async {
    final bool serviceEnabled = await platform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException(
        'Layanan lokasi (GPS) pada perangkat tidak aktif. Silakan aktifkan GPS.',
      );
    }

    geo.LocationPermission permission = await platform.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await platform.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw const LocationPermissionException(
          'Izin akses lokasi ditolak oleh pengguna.',
          isPermanentlyDenied: false,
        );
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Izin akses lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.',
        isPermanentlyDenied: true,
      );
    }

    try {
      final position = await platform.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return UserLocationEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } on TimeoutException {
      throw const LocationPermissionException(
        'Waktu permintaan lokasi habis (timeout). Silakan coba lagi.',
      );
    } on geo.LocationServiceDisabledException {
      throw const LocationServiceDisabledException(
        'Layanan lokasi (GPS) pada perangkat tidak aktif. Silakan aktifkan GPS.',
      );
    } catch (e) {
      if (e is LocationPermissionException || e is LocationServiceDisabledException) {
        rethrow;
      }
      throw LocationPermissionException('Gagal mengambil koordinat lokasi: $e');
    }
  }

  @override
  Future<bool> openAppSettings() async {
    return await platform.openAppSettings();
  }
}
