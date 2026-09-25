import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/errors/failures.dart';
import 'package:mapid/core/utils/either.dart';
import 'package:mapid/features/map/domain/entities/map_feature_entity.dart';
import 'package:mapid/features/map/domain/entities/user_location_entity.dart';
import 'package:mapid/features/map/domain/usecases/get_layer_data_usecase.dart';
import 'package:mapid/features/map/domain/usecases/get_user_location_usecase.dart';
import 'package:mapid/features/map/presentation/cubit/map_cubit.dart';
import 'package:mapid/features/map/presentation/cubit/map_state.dart';

class MockGetLayerDataUseCase extends Mock implements GetLayerDataUseCase {}

class MockGetUserLocationUseCase extends Mock implements GetUserLocationUseCase {}

void main() {
  late MockGetLayerDataUseCase mockGetLayerDataUseCase;
  late MockGetUserLocationUseCase mockGetUserLocationUseCase;
  late MapCubit mapCubit;

  setUp(() {
    mockGetLayerDataUseCase = MockGetLayerDataUseCase();
    mockGetUserLocationUseCase = MockGetUserLocationUseCase();
    mapCubit = MapCubit(
      getLayerDataUseCase: mockGetLayerDataUseCase,
      getUserLocationUseCase: mockGetUserLocationUseCase,
    );
  });

  tearDown(() {
    mapCubit.close();
  });

  const testFeature = MapFeatureEntity(
    id: '1',
    name: 'Keraton Yogyakarta',
    address: 'Jl. Rotowijayan Blok No. 1',
    district: 'Kraton',
    recordTime: '2024-09-24',
    latitude: -7.8003,
    longitude: 110.3672,
  );

  group('MapCubit Tests', () {
    test('initial state should have MapStatus.initial and empty features', () {
      expect(mapCubit.state.status, MapStatus.initial);
      expect(mapCubit.state.features, isEmpty);
      expect(mapCubit.state.selectedFeature, isNull);
    });

    blocTest<MapCubit, MapState>(
      'emits [MapStatus.loading, MapStatus.loaded] when loadLayerData succeeds with features',
      build: () {
        when(() => mockGetLayerDataUseCase())
            .thenAnswer((_) async => const Right([testFeature]));
        return mapCubit;
      },
      act: (cubit) => cubit.loadLayerData(),
      expect: () => [
        const MapState(status: MapStatus.loading),
        const MapState(
          status: MapStatus.loaded,
          features: [testFeature],
        ),
      ],
      verify: (_) {
        verify(() => mockGetLayerDataUseCase()).called(1);
      },
    );

    blocTest<MapCubit, MapState>(
      'emits [MapStatus.loading, MapStatus.empty] when loadLayerData succeeds with empty list',
      build: () {
        when(() => mockGetLayerDataUseCase())
            .thenAnswer((_) async => const Right([]));
        return mapCubit;
      },
      act: (cubit) => cubit.loadLayerData(),
      expect: () => [
        const MapState(status: MapStatus.loading),
        const MapState(
          status: MapStatus.empty,
          features: [],
        ),
      ],
    );

    blocTest<MapCubit, MapState>(
      'emits [MapStatus.loading, MapStatus.failure] when loadLayerData fails',
      build: () {
        when(() => mockGetLayerDataUseCase())
            .thenAnswer((_) async => const Left(ServerFailure('API error', 500)));
        return mapCubit;
      },
      act: (cubit) => cubit.loadLayerData(),
      expect: () => [
        const MapState(status: MapStatus.loading),
        const MapState(
          status: MapStatus.failure,
          errorMessage: 'API error',
        ),
      ],
    );

    blocTest<MapCubit, MapState>(
      'selectFeature and clearSelectedFeature should update selectedFeature state properly',
      build: () => mapCubit,
      act: (cubit) {
        cubit.selectFeature(testFeature);
        cubit.clearSelectedFeature();
      },
      expect: () => [
        const MapState(selectedFeature: testFeature),
        const MapState(selectedFeature: null),
      ],
    );

    final localLocation = UserLocationEntity(
      latitude: -7.7956,
      longitude: 110.3695,
      accuracy: 5.0,
      timestamp: DateTime(2026, 9, 24),
    );

    final remoteLocation = UserLocationEntity(
      latitude: 37.4220,
      longitude: -122.0841,
      accuracy: 10.0,
      timestamp: DateTime(2026, 9, 24),
    );

    blocTest<MapCubit, MapState>(
      'getUserLocation emits [isLocationLoading: true] then location state with showYogyakartaReturnChip: false when within 50 km',
      build: () {
        when(() => mockGetUserLocationUseCase())
            .thenAnswer((_) async => Right(localLocation));
        return mapCubit;
      },
      act: (cubit) => cubit.getUserLocation(),
      expect: () => [
        const MapState(isLocationLoading: true),
        MapState(
          isLocationLoading: false,
          userLocation: localLocation,
          showYogyakartaReturnChip: false,
        ),
      ],
      verify: (_) {
        verify(() => mockGetUserLocationUseCase()).called(1);
      },
    );

    blocTest<MapCubit, MapState>(
      'getUserLocation emits [isLocationLoading: true] then location state with showYogyakartaReturnChip: true when >50 km (Mountain View)',
      build: () {
        when(() => mockGetUserLocationUseCase())
            .thenAnswer((_) async => Right(remoteLocation));
        return mapCubit;
      },
      act: (cubit) => cubit.getUserLocation(),
      expect: () => [
        const MapState(isLocationLoading: true),
        MapState(
          isLocationLoading: false,
          userLocation: remoteLocation,
          showYogyakartaReturnChip: true,
        ),
      ],
      verify: (_) {
        verify(() => mockGetUserLocationUseCase()).called(1);
      },
    );

    blocTest<MapCubit, MapState>(
      'getUserLocation emits failure when use case returns Failure',
      build: () {
        when(() => mockGetUserLocationUseCase()).thenAnswer(
          (_) async => const Left(
            LocationPermissionFailure('Izin ditolak', isPermanentlyDenied: false),
          ),
        );
        return mapCubit;
      },
      act: (cubit) => cubit.getUserLocation(),
      expect: () => [
        const MapState(isLocationLoading: true),
        const MapState(
          isLocationLoading: false,
          locationFailure: LocationPermissionFailure('Izin ditolak', isPermanentlyDenied: false),
          errorMessage: 'Izin ditolak',
        ),
      ],
    );

    blocTest<MapCubit, MapState>(
      'recenterToYogyakarta sets showYogyakartaReturnChip to false',
      build: () => mapCubit,
      seed: () => const MapState(showYogyakartaReturnChip: true),
      act: (cubit) => cubit.recenterToYogyakarta(),
      expect: () => [
        const MapState(showYogyakartaReturnChip: false),
      ],
    );

    blocTest<MapCubit, MapState>(
      'clearLocationFailure resets locationFailure to null',
      build: () => mapCubit,
      seed: () => const MapState(
        locationFailure: LocationPermissionFailure('Error'),
      ),
      act: (cubit) => cubit.clearLocationFailure(),
      expect: () => [
        const MapState(locationFailure: null),
      ],
    );

    test('openAppSettings delegates to provided handler', () async {
      var handlerCalled = false;
      final customCubit = MapCubit(
        getLayerDataUseCase: mockGetLayerDataUseCase,
        getUserLocationUseCase: mockGetUserLocationUseCase,
        openAppSettingsHandler: () async {
          handlerCalled = true;
          return true;
        },
      );

      final result = await customCubit.openAppSettings();
      expect(result, isTrue);
      expect(handlerCalled, isTrue);
      await customCubit.close();
    });
  });

  group('MapState Tests', () {
    test('supports value equality and copyWith correctly', () {
      const state1 = MapState(
        status: MapStatus.loaded,
        features: [testFeature],
        selectedFeature: testFeature,
        errorMessage: 'Some error',
      );

      const state2 = MapState(
        status: MapStatus.loaded,
        features: [testFeature],
        selectedFeature: testFeature,
        errorMessage: 'Some error',
      );

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1.toString(), contains('Keraton Yogyakarta'));

      // copyWith clearing flags
      final cleared = state1.copyWith(
        clearSelectedFeature: true,
        clearErrorMessage: true,
        clearLocationFailure: true,
      );
      expect(cleared.selectedFeature, isNull);
      expect(cleared.errorMessage, isNull);
      expect(cleared.locationFailure, isNull);
    });
  });
}
