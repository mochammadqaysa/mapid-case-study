import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/errors/exceptions.dart';
import 'package:mapid/features/map/data/datasources/location_data_source.dart';

class MockGeolocatorPlatform extends Mock implements geo.GeolocatorPlatform {}

class FakeLocationSettings extends Fake implements geo.LocationSettings {}

void main() {
  late MockGeolocatorPlatform mockPlatform;
  late LocationDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(FakeLocationSettings());
  });

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    dataSource = LocationDataSource(platform: mockPlatform);
  });

  final testPosition = geo.Position(
    latitude: -7.7956,
    longitude: 110.3695,
    timestamp: DateTime(2026, 9, 24, 10, 0),
    accuracy: 5.0,
    altitude: 100.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  group('LocationDataSource Tests', () {
    test('isLocationServiceEnabled delegates to platform', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);

      final result = await dataSource.isLocationServiceEnabled();

      expect(result, isTrue);
      verify(() => mockPlatform.isLocationServiceEnabled()).called(1);
    });

    test('checkPermission returns true when permission is whileInUse or always', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.whileInUse);

      final resultWhileInUse = await dataSource.checkPermission();
      expect(resultWhileInUse, isTrue);

      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.always);

      final resultAlways = await dataSource.checkPermission();
      expect(resultAlways, isTrue);
    });

    test('checkPermission returns false when permission is denied or deniedForever', () async {
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.denied);

      final resultDenied = await dataSource.checkPermission();
      expect(resultDenied, isFalse);

      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.deniedForever);

      final resultDeniedForever = await dataSource.checkPermission();
      expect(resultDeniedForever, isFalse);
    });

    test('requestPermission returns true when granted', () async {
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => geo.LocationPermission.whileInUse);

      final result = await dataSource.requestPermission();

      expect(result, isTrue);
      verify(() => mockPlatform.requestPermission()).called(1);
    });

    test('getCurrentLocation throws LocationServiceDisabledException when service is disabled', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      await expectLater(
        dataSource.getCurrentLocation(),
        throwsA(isA<LocationServiceDisabledException>()),
      );
      verify(() => mockPlatform.isLocationServiceEnabled()).called(1);
      verifyNever(() => mockPlatform.checkPermission());
    });

    test('getCurrentLocation requests permission when initially denied, and throws if still denied', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.denied);
      when(() => mockPlatform.requestPermission())
          .thenAnswer((_) async => geo.LocationPermission.denied);

      await expectLater(
        dataSource.getCurrentLocation(),
        throwsA(predicate((e) =>
            e is LocationPermissionException && !e.isPermanentlyDenied)),
      );
      verify(() => mockPlatform.checkPermission()).called(1);
      verify(() => mockPlatform.requestPermission()).called(1);
    });

    test('getCurrentLocation throws LocationPermissionException with isPermanentlyDenied when deniedForever', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.deniedForever);

      await expectLater(
        dataSource.getCurrentLocation(),
        throwsA(predicate((e) =>
            e is LocationPermissionException && e.isPermanentlyDenied)),
      );
    });

    test('getCurrentLocation returns UserLocationEntity on valid position', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.whileInUse);
      when(() => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).thenAnswer((_) async => testPosition);

      final location = await dataSource.getCurrentLocation();

      expect(location.latitude, -7.7956);
      expect(location.longitude, 110.3695);
      expect(location.accuracy, 5.0);
      expect(location.timestamp, testPosition.timestamp);
    });

    test('getCurrentLocation translates TimeoutException into LocationPermissionException', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.whileInUse);
      when(() => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).thenThrow(TimeoutException('Request timed out'));

      expect(
        () => dataSource.getCurrentLocation(),
        throwsA(isA<LocationPermissionException>()),
      );
    });

    test('openAppSettings delegates to platform', () async {
      when(() => mockPlatform.openAppSettings()).thenAnswer((_) async => true);

      final result = await dataSource.openAppSettings();

      expect(result, isTrue);
      verify(() => mockPlatform.openAppSettings()).called(1);
    });
  });
}
