import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/errors/failures.dart';
import 'package:mapid/core/utils/either.dart';
import 'package:mapid/features/map/domain/entities/map_feature_entity.dart';
import 'package:mapid/features/map/domain/repositories/map_repository.dart';
import 'package:mapid/features/map/domain/usecases/get_layer_data_usecase.dart';

class MockMapRepository extends Mock implements MapRepository {}

void main() {
  late MockMapRepository mockRepository;
  late GetLayerDataUseCase useCase;

  setUp(() {
    mockRepository = MockMapRepository();
    useCase = GetLayerDataUseCase(mockRepository);
  });

  const sampleFeature = MapFeatureEntity(
    id: '1',
    name: 'Keraton Yogyakarta',
    address: 'Jl. Rotowijayan',
    district: 'Kraton',
    recordTime: '2024-09-24',
    latitude: -7.8003,
    longitude: 110.3672,
  );

  group('GetLayerDataUseCase Tests', () {
    test('should forward getLayerData call to MapRepository and return features', () async {
      when(() => mockRepository.getLayerData())
          .thenAnswer((_) async => const Right([sampleFeature]));

      final result = await useCase();

      expect(result.isRight, isTrue);
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r, [sampleFeature]),
      );
      verify(() => mockRepository.getLayerData()).called(1);
    });

    test('should return Failure when MapRepository fails', () async {
      when(() => mockRepository.getLayerData())
          .thenAnswer((_) async => const Left(ServerFailure('Error')));

      final result = await useCase();

      expect(result.isLeft, isTrue);
      result.fold(
        (l) => expect(l, const ServerFailure('Error')),
        (r) => fail('Should be left'),
      );
    });
  });
}
