import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/map_feature_entity.dart';
import '../../domain/entities/user_location_entity.dart';

/// Lifecycle status for map layer operations (REQ-007).
enum MapStatus { initial, loading, loaded, empty, failure }

/// State container for MAPID Mobile GIS (REQ-007, CON-001).
class MapState {
  final MapStatus status;
  final List<MapFeatureEntity> features;
  final MapFeatureEntity? selectedFeature;
  final UserLocationEntity? userLocation;
  final bool isLocationLoading;
  final bool showYogyakartaReturnChip;
  final String? errorMessage;
  final Failure? locationFailure;

  const MapState({
    this.status = MapStatus.initial,
    this.features = const [],
    this.selectedFeature,
    this.userLocation,
    this.isLocationLoading = false,
    this.showYogyakartaReturnChip = false,
    this.errorMessage,
    this.locationFailure,
  });

  MapState copyWith({
    MapStatus? status,
    List<MapFeatureEntity>? features,
    MapFeatureEntity? selectedFeature,
    bool clearSelectedFeature = false,
    UserLocationEntity? userLocation,
    bool? isLocationLoading,
    bool? showYogyakartaReturnChip,
    String? errorMessage,
    bool clearErrorMessage = false,
    Failure? locationFailure,
    bool clearLocationFailure = false,
  }) {
    return MapState(
      status: status ?? this.status,
      features: features ?? this.features,
      selectedFeature: clearSelectedFeature
          ? null
          : (selectedFeature ?? this.selectedFeature),
      userLocation: userLocation ?? this.userLocation,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      showYogyakartaReturnChip:
          showYogyakartaReturnChip ?? this.showYogyakartaReturnChip,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      locationFailure:
          clearLocationFailure ? null : (locationFailure ?? this.locationFailure),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          listEquals(features, other.features) &&
          selectedFeature == other.selectedFeature &&
          userLocation == other.userLocation &&
          isLocationLoading == other.isLocationLoading &&
          showYogyakartaReturnChip == other.showYogyakartaReturnChip &&
          errorMessage == other.errorMessage &&
          locationFailure == other.locationFailure;

  @override
  int get hashCode => Object.hash(
        status,
        Object.hashAll(features),
        selectedFeature,
        userLocation,
        isLocationLoading,
        showYogyakartaReturnChip,
        errorMessage,
        locationFailure,
      );

  @override
  String toString() =>
      'MapState(status: $status, featuresCount: ${features.length}, selected: ${selectedFeature?.name}, userLocation: $userLocation, chip: $showYogyakartaReturnChip, locFailure: $locationFailure, error: $errorMessage)';
}
