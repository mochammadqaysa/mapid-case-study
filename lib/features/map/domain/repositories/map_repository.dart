import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/map_feature_entity.dart';
import '../entities/user_location_entity.dart';

/// Repository interface contract for map data operations (CON-001).
abstract class MapRepository {
  /// Fetches GeoJSON Layer Data from GEO MAPID and transforms it into domain entities.
  Future<Either<Failure, List<MapFeatureEntity>>> getLayerData();

  /// Acquires user GPS location on-demand.
  Future<Either<Failure, UserLocationEntity>> getUserLocation();

  /// Checks if location permission is granted.
  Future<bool> checkLocationPermission();

  /// Prompts user for location permission.
  Future<bool> requestLocationPermission();

  /// Opens system application settings for manual permission management.
  Future<bool> openAppSettings();
}
