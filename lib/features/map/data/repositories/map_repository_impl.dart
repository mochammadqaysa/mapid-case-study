import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/map_feature_entity.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/geomapid_remote_data_source.dart';
import '../datasources/location_data_source.dart';

/// Implementation of [MapRepository] bridging data sources to domain layer (CON-001).
class MapRepositoryImpl implements MapRepository {
  final IGeoMapidRemoteDataSource remoteDataSource;
  final ILocationDataSource locationDataSource;

  MapRepositoryImpl({
    required this.remoteDataSource,
    ILocationDataSource? locationDataSource,
  }) : locationDataSource = locationDataSource ?? LocationDataSource();

  @override
  Future<Either<Failure, List<MapFeatureEntity>>> getLayerData() async {
    try {
      final response = await remoteDataSource.getLayerData();
      final entities = response.features.map((f) => f.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserLocationEntity>> getUserLocation() async {
    try {
      final userLocation = await locationDataSource.getCurrentLocation();
      return Right(userLocation);
    } on LocationServiceDisabledException catch (e) {
      return Left(LocationServiceDisabledFailure(e.message));
    } on LocationPermissionException catch (e) {
      return Left(
        LocationPermissionFailure(
          e.message,
          isPermanentlyDenied: e.isPermanentlyDenied,
        ),
      );
    } catch (e) {
      return Left(LocationPermissionFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<bool> checkLocationPermission() async {
    return await locationDataSource.checkPermission();
  }

  @override
  Future<bool> requestLocationPermission() async {
    return await locationDataSource.requestPermission();
  }

  @override
  Future<bool> openAppSettings() async {
    return await locationDataSource.openAppSettings();
  }
}
