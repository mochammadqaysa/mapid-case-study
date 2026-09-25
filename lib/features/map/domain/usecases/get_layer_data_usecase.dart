import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/map_feature_entity.dart';
import '../repositories/map_repository.dart';

/// Domain usecase to fetch Layer Data from the repository (REQ-002, CON-001).
class GetLayerDataUseCase {
  final MapRepository repository;

  const GetLayerDataUseCase(this.repository);

  Future<Either<Failure, List<MapFeatureEntity>>> call() {
    return repository.getLayerData();
  }
}
