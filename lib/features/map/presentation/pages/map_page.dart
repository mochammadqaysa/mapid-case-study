import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/datasources/geomapid_remote_data_source.dart';
import '../../data/datasources/location_data_source.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/usecases/get_layer_data_usecase.dart';
import '../../domain/usecases/get_user_location_usecase.dart';
import '../cubit/map_cubit.dart';
import '../cubit/map_state.dart';
import '../widgets/error_card.dart';
import '../widgets/map_view_widget.dart';
import '../widgets/poi_detail_sheet.dart';
import '../widgets/return_to_yogyakarta_chip.dart';
import '../widgets/user_location_button.dart';

/// Primary page assembling the GIS map view, layer state orchestration, overlays, and controls.
class MapPage extends StatefulWidget {
  final IEnvConfig envConfig;
  final MapCubit? cubit;
  final Widget Function(BuildContext context)? customMapBuilder;

  const MapPage({
    super.key,
    required this.envConfig,
    this.cubit,
    this.customMapBuilder,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapCubit _cubit;
  late final bool _isInternalCubit;
  http.Client? _httpClient;
  final GlobalKey<MapViewWidgetState> _mapViewKey = GlobalKey<MapViewWidgetState>();
  bool _isStyleLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isInternalCubit = false;
    } else {
      _httpClient = http.Client();
      final remoteDataSource = GeoMapidRemoteDataSource(
        client: _httpClient!,
        envConfig: widget.envConfig,
      );
      final locationDataSource = LocationDataSource();
      final repository = MapRepositoryImpl(
        remoteDataSource: remoteDataSource,
        locationDataSource: locationDataSource,
      );
      final getLayerDataUseCase = GetLayerDataUseCase(repository);
      final getUserLocationUseCase = GetUserLocationUseCase(repository);
      _cubit = MapCubit(
        getLayerDataUseCase: getLayerDataUseCase,
        getUserLocationUseCase: getUserLocationUseCase,
        openAppSettingsHandler: () => repository.openAppSettings(),
      );
      _isInternalCubit = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalCubit) {
      _cubit.close();
      _httpClient?.close();
    }
    super.dispose();
  }


  void _handleStyleLoaded() {
    if (!mounted) return;
    setState(() {
      _isStyleLoaded = true;
    });
    // Trigger GeoJSON layer data ingestion once basemap style is loaded (REQ-002, REQ-003)
    _cubit.loadLayerData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<MapCubit, MapState>(
        listenWhen: (previous, current) =>
            previous.locationFailure != current.locationFailure &&
            current.locationFailure != null,
        listener: (context, state) {
          final failure = state.locationFailure;
          if (failure == null) return;

          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();

          if (failure is LocationServiceDisabledFailure) {
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.textPrimary,
                content: Row(
                  children: [
                    const Icon(Icons.location_off, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        failure.message.isNotEmpty
                            ? failure.message
                            : 'Layanan lokasi (GPS) tidak aktif. Silakan aktifkan GPS.',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Pengaturan',
                  textColor: AppColors.primaryLight,
                  onPressed: () => _cubit.openAppSettings(),
                ),
              ),
            );
          } else if (failure is LocationPermissionFailure) {
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.textPrimary,
                content: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        failure.message,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 4),
                action: failure.isPermanentlyDenied
                    ? SnackBarAction(
                        label: 'Pengaturan',
                        textColor: AppColors.primaryLight,
                        onPressed: () => _cubit.openAppSettings(),
                      )
                    : null,
              ),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                content: Text(failure.message),
              ),
            );
          }
          _cubit.clearLocationFailure();
        },
        child: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            final statusInfo = _getStatusInfo(state);
            final screenHeight = MediaQuery.sizeOf(context).height;
            final isLandscape =
                MediaQuery.orientationOf(context) == Orientation.landscape;

            // Calculate adaptive bottom sheet clearance (CON-001, antislop-layoutmobile)
            final double sheetClearance = isLandscape
                ? (screenHeight * 0.45).clamp(140.0, 180.0)
                : (screenHeight * 0.35).clamp(180.0, 240.0);

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                scrolledUnderElevation: 1,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'MAPID Mobile GIS',
                      style: AppTextStyles.headingMedium,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusInfo.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusInfo.label,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: AppColors.border,
                    height: 1.0,
                  ),
                ),
              ),
              body: Stack(
                children: [
                  // 1. Vector Basemap & Feature Layer
                  Positioned.fill(
                    child: MapViewWidget(
                      key: _mapViewKey,
                      envConfig: widget.envConfig,
                      features: state.features,
                      userLocation: state.userLocation,
                      onStyleLoaded: _handleStyleLoaded,
                      onFeatureTapped: (feature) {
                        _cubit.selectFeature(feature);
                      },
                      onMapClick: () {
                        _cubit.clearSelectedFeature();
                      },
                      customMapBuilder: widget.customMapBuilder,
                    ),
                  ),

                  // 2. Error Notification Banner with Retry Action (REQ-007, AC-007)
                  if (state.status == MapStatus.failure && state.errorMessage != null)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: ErrorCard(
                        errorMessage: state.errorMessage!,
                        onRetry: () => _cubit.loadLayerData(),
                      ),
                    ),

                  // 3. Floating "Kembali ke Yogyakarta" Recenter Chip (REQ-006, ADR-0001)
                  if (state.showYogyakartaReturnChip)
                    Positioned(
                      top: (state.status == MapStatus.failure && state.errorMessage != null)
                          ? 76
                          : 16,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: ReturnToYogyakartaChip(
                          onTap: () {
                            _mapViewKey.currentState?.animateCameraToYogyakarta();
                            _cubit.recenterToYogyakarta();
                          },
                        ),
                      ),
                    ),

                  // 4. Cartographic Attribution Badge (Antislop compliant)
                  Positioned(
                    left: 12,
                    bottom: state.selectedFeature != null ? sheetClearance : 12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: const Text(
                        '© OpenFreeMap • © OpenStreetMap',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),

                  // 5. On-Demand User Location Floating Action Button (REQ-005, GUD-001)
                  Positioned(
                    right: 16,
                    bottom: state.selectedFeature != null ? sheetClearance : 60,
                    child: UserLocationButton(
                      isLoading: state.isLocationLoading,
                      onPressed: () async {
                        final previousLocation = _cubit.state.userLocation;
                        await _cubit.getUserLocation();
                        // Re-center explicitly only if the coordinates did not change (e.g. user panned away)
                        // because didUpdateWidget only triggers when userLocation changes.
                        if (mounted &&
                            _cubit.state.userLocation != null &&
                            _cubit.state.userLocation == previousLocation) {
                          _mapViewKey.currentState?.animateCameraToUserLocation(
                            _cubit.state.userLocation!,
                          );
                        }
                      },

                    ),
                  ),

                  // 6. Feature Point Popup Detail Bottom Sheet (REQ-004, AC-003, AC-004)
                  if (state.selectedFeature != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: PoiDetailSheet(
                        key: ValueKey(state.selectedFeature!.id),
                        feature: state.selectedFeature!,
                        onClose: () => _cubit.clearSelectedFeature(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ({String label, Color color}) _getStatusInfo(MapState state) {
    if (!_isStyleLoaded) {
      return (label: 'Loading Basemap...', color: AppColors.warning);
    }

    return switch (state.status) {
      MapStatus.loading => (
          label: 'Memuat Layer...',
          color: AppColors.primaryLight,
        ),
      MapStatus.loaded => (
          label: 'Layer Aktif (${state.features.length} Titik)',
          color: AppColors.success,
        ),
      MapStatus.empty => (
          label: 'Layer Kosong',
          color: AppColors.warning,
        ),
      MapStatus.failure => (
          label: 'Gagal Memuat Layer',
          color: AppColors.error,
        ),
      MapStatus.initial => (
          label: 'Basemap Ready',
          color: AppColors.success,
        ),
    };
  }
}
