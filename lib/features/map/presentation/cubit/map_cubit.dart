import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../domain/entities/map_feature_entity.dart';
import '../../domain/usecases/get_layer_data_usecase.dart';
import '../../domain/usecases/get_user_location_usecase.dart';
import 'map_state.dart';

/// Presentation state machine orchestrating map layer lifecycle, selection, and location (REQ-007, ADR-0001).
class MapCubit extends Cubit<MapState> {
  final GetLayerDataUseCase getLayerDataUseCase;
  final GetUserLocationUseCase? getUserLocationUseCase;
  final Future<bool> Function()? openAppSettingsHandler;

  MapCubit({
    required this.getLayerDataUseCase,
    this.getUserLocationUseCase,
    this.openAppSettingsHandler,
  }) : super(const MapState());

  /// Loads Layer Data from remote GEO MAPID endpoint.
  Future<void> loadLayerData() async {
    debugPrint('[MapCubit] loadLayerData() called. Emitting MapStatus.loading...');
    emit(state.copyWith(
      status: MapStatus.loading,
      clearErrorMessage: true,
    ));

    final result = await getLayerDataUseCase();

    result.fold(
      (failure) {
        debugPrint(
          '[MapCubit] loadLayerData FAILED: [${failure.runtimeType}] ${failure.message}',
        );
        emit(state.copyWith(
          status: MapStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (features) {
        if (features.isEmpty) {
          debugPrint('[MapCubit] loadLayerData SUCCESS: 0 features returned (Empty).');
          emit(state.copyWith(
            status: MapStatus.empty,
            features: const [],
          ));
        } else {
          debugPrint(
            '[MapCubit] loadLayerData SUCCESS: ${features.length} feature(s) loaded.',
          );
          emit(state.copyWith(
            status: MapStatus.loaded,
            features: features,
          ));
        }
      },
    );
  }

  /// Selects a specific Feature Point and triggers detail view presentation.
  void selectFeature(MapFeatureEntity feature) {
    emit(state.copyWith(selectedFeature: feature));
  }

  /// Clears the currently active Feature Point selection.
  void clearSelectedFeature() {
    emit(state.copyWith(clearSelectedFeature: true));
  }

  /// Acquires device GPS location on-demand and checks Yogyakarta boundary (REQ-005, REQ-006, ADR-0001).
  Future<void> getUserLocation() async {
    emit(state.copyWith(
      isLocationLoading: true,
      clearLocationFailure: true,
    ));

    if (getUserLocationUseCase == null) {
      emit(state.copyWith(
        isLocationLoading: false,
        locationFailure: const LocationPermissionFailure('Use case lokasi tidak tersedia.'),
      ));
      return;
    }

    final result = await getUserLocationUseCase!();

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLocationLoading: false,
          locationFailure: failure,
          errorMessage: failure.message,
        ));
      },
      (location) {
        final isFar = DistanceCalculator.isOutsideYogyakartaThreshold(
          latitude: location.latitude,
          longitude: location.longitude,
        );

        emit(state.copyWith(
          isLocationLoading: false,
          userLocation: location,
          showYogyakartaReturnChip: isFar,
          clearLocationFailure: true,
          clearErrorMessage: true,
        ));
      },
    );
  }

  /// Dismisses Yogyakarta return chip and resets chip state (REQ-006).
  void recenterToYogyakarta() {
    emit(state.copyWith(showYogyakartaReturnChip: false));
  }

  /// Clears current location failure to avoid re-triggering notifications.
  void clearLocationFailure() {
    emit(state.copyWith(clearLocationFailure: true));
  }

  /// Opens system app settings for permission management.
  Future<bool> openAppSettings() async {
    if (openAppSettingsHandler != null) {
      return await openAppSettingsHandler!();
    }
    return false;
  }
}
