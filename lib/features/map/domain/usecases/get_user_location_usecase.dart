import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_location_entity.dart';
import '../repositories/map_repository.dart';

/// Domain use case for acquiring on-demand hardware GPS User Location (REQ-005, ADR-0001).
class GetUserLocationUseCase {
  final MapRepository repository;

  const GetUserLocationUseCase(this.repository);

  Future<Either<Failure, UserLocationEntity>> call() {
    return repository.getUserLocation();
  }
}
