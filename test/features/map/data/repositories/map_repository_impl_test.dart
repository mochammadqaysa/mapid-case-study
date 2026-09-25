import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/errors/exceptions.dart';
import 'package:mapid/core/errors/failures.dart';
import 'package:mapid/features/map/data/datasources/geomapid_remote_data_source.dart';
import 'package:mapid/features/map/data/datasources/location_data_source.dart';
import 'package:mapid/features/map/data/models/geojson_feature_model.dart';
import 'package:mapid/features/map/data/repositories/map_repository_impl.dart';
import 'package:mapid/features/map/domain/entities/user_location_entity.dart';

class MockGeoMapidRemoteDataSource extends Mock
    implements IGeoMapidRemoteDataSource {}

class MockLocationDataSource extends Mock implements ILocationDataSource {}

void main() {
  late MockGeoMapidRemoteDataSource mockDataSource;
  late MockLocationDataSource mockLocationDataSource;
  late MapRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockGeoMapidRemoteDataSource();
    mockLocationDataSource = MockLocationDataSource();
    repository = MapRepositoryImpl(
      remoteDataSource: mockDataSource,
      locationDataSource: mockLocationDataSource,
    );
  });

  const sampleFeatureModel = GeoJsonFeatureModel(
    type: 'Feature',
    geometry: GeoJsonGeometryModel(
      type: 'Point',
      longitude: 110.3672,
      latitude: -7.8003,
    ),
    properties: GeoJsonPropertiesModel(
      name: 'Keraton Yogyakarta',
      address: 'Jl. Rotowijayan',
      district: 'Kraton',
      recordTime: '2024-09-24',
    ),
  );

  const sampleResponse = LayerResponseModel(
    type: 'FeatureCollection',
    features: [sampleFeatureModel],
  );

  group('MapRepositoryImpl Tests', () {
    test('should return Right(List<MapFeatureEntity>) on successful remote call', () async {
      when(() => mockDataSource.getLayerData())
          .thenAnswer((_) async => sampleResponse);

      final result = await repository.getLayerData();

      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Expected Right, got Left: $failure'),
        (features) {
          expect(features.length, 1);
          expect(features.first.name, 'Keraton Yogyakarta');
          expect(features.first.district, 'Kraton');
        },
      );
      verify(() => mockDataSource.getLayerData()).called(1);
    });

    test('should return Left(ServerFailure) when remote datasource throws ServerException', () async {
      when(() => mockDataSource.getLayerData())
          .thenThrow(const ServerException('Unauthorized', statusCode: 401));

      final result = await repository.getLayerData();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).statusCode, 401);
        },
        (_) => fail('Expected Left, got Right'),
      );
    });

    test('should return Left(NetworkFailure) when remote datasource throws NetworkException', () async {
      when(() => mockDataSource.getLayerData())
          .thenThrow(const NetworkException('No connection'));

      final result = await repository.getLayerData();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left, got Right'),
      );
    });
  });

  group('MapRepositoryImpl Location Operations', () {
    final sampleLocation = UserLocationEntity(
      latitude: -7.7956,
      longitude: 110.3695,
      accuracy: 5.0,
      timestamp: DateTime(2026, 9, 24),
    );

    test('should return Right(UserLocationEntity) when location data source succeeds', () async {
      when(() => mockLocationDataSource.getCurrentLocation())
          .thenAnswer((_) async => sampleLocation);

      final result = await repository.getUserLocation();

      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Expected Right, got Left: $failure'),
        (location) => expect(location, sampleLocation),
      );
      verify(() => mockLocationDataSource.getCurrentLocation()).called(1);
    });

    test('should return Left(LocationServiceDisabledFailure) when location service is disabled', () async {
      when(() => mockLocationDataSource.getCurrentLocation())
          .thenThrow(const LocationServiceDisabledException('GPS disabled'));

      final result = await repository.getUserLocation();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<LocationServiceDisabledFailure>()),
        (_) => fail('Expected Left, got Right'),
      );
    });

    test('should return Left(LocationPermissionFailure) with isPermanentlyDenied when denied forever', () async {
      when(() => mockLocationDataSource.getCurrentLocation()).thenThrow(
        const LocationPermissionException('Denied forever', isPermanentlyDenied: true),
      );

      final result = await repository.getUserLocation();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<LocationPermissionFailure>());
          expect((failure as LocationPermissionFailure).isPermanentlyDenied, isTrue);
        },
        (_) => fail('Expected Left, got Right'),
      );
    });

    test('should return Left(LocationPermissionFailure) when denied temporarily', () async {
      when(() => mockLocationDataSource.getCurrentLocation()).thenThrow(
        const LocationPermissionException('Denied', isPermanentlyDenied: false),
      );

      final result = await repository.getUserLocation();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<LocationPermissionFailure>());
          expect((failure as LocationPermissionFailure).isPermanentlyDenied, isFalse);
        },
        (_) => fail('Expected Left, got Right'),
      );
    });

    test('should forward checkLocationPermission and requestLocationPermission calls', () async {
      when(() => mockLocationDataSource.checkPermission())
          .thenAnswer((_) async => true);
      when(() => mockLocationDataSource.requestPermission())
          .thenAnswer((_) async => true);
      when(() => mockLocationDataSource.openAppSettings())
          .thenAnswer((_) async => true);

      expect(await repository.checkLocationPermission(), isTrue);
      expect(await repository.requestLocationPermission(), isTrue);
      expect(await repository.openAppSettings(), isTrue);

      verify(() => mockLocationDataSource.checkPermission()).called(1);
      verify(() => mockLocationDataSource.requestPermission()).called(1);
      verify(() => mockLocationDataSource.openAppSettings()).called(1);
    });
  });
}
