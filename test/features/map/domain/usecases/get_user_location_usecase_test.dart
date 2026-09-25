import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/errors/failures.dart';
import 'package:mapid/core/utils/either.dart';
import 'package:mapid/features/map/domain/entities/user_location_entity.dart';
import 'package:mapid/features/map/domain/repositories/map_repository.dart';
import 'package:mapid/features/map/domain/usecases/check_location_permission_usecase.dart';
import 'package:mapid/features/map/domain/usecases/get_user_location_usecase.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  late MockMapRepository mockRepository;
  late GetUserLocationUseCase getUserLocationUseCase;
  late CheckLocationPermissionUseCase checkLocationPermissionUseCase;

  setUp(() {
    mockRepository = MockMapRepository();
    getUserLocationUseCase = GetUserLocationUseCase(mockRepository);
    checkLocationPermissionUseCase = CheckLocationPermissionUseCase(mockRepository);
  });

  final testUserLocation = UserLocationEntity(
    latitude: -7.7956,
    longitude: 110.3695,
    accuracy: 3.5,
    timestamp: DateTime(2026, 9, 24, 10, 0),
  );

  group('GetUserLocationUseCase Tests', () {
    test('should forward getUserLocation call to MapRepository and return user location', () async {
      when(() => mockRepository.getUserLocation())
          .thenAnswer((_) async => Right(testUserLocation));

      final result = await getUserLocationUseCase();

      expect(result.isRight, isTrue);
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r, testUserLocation),
      );
      verify(() => mockRepository.getUserLocation()).called(1);
    });

    test('should return Failure when MapRepository fails', () async {
      const failure = LocationPermissionFailure('Izin lokasi ditolak');
      when(() => mockRepository.getUserLocation())
          .thenAnswer((_) async => const Left(failure));

      final result = await getUserLocationUseCase();

      expect(result.isLeft, isTrue);
      result.fold(
        (l) => expect(l, failure),
        (r) => fail('Should be left'),
      );
      verify(() => mockRepository.getUserLocation()).called(1);
    });
  });

  group('CheckLocationPermissionUseCase Tests', () {
    test('should forward checkLocationPermission call to MapRepository', () async {
      when(() => mockRepository.checkLocationPermission())
          .thenAnswer((_) async => true);

      final result = await checkLocationPermissionUseCase();

      expect(result, isTrue);
      verify(() => mockRepository.checkLocationPermission()).called(1);
    });
  });
}
