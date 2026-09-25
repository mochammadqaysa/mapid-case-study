import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/map_feature_entity.dart';
import '../../domain/entities/user_location_entity.dart';

/// Reusable MapLibre GL Basemap widget wrapper (REQ-001, REQ-003, REQ-005, CON-002, CON-003).
///
/// Encapsulates map camera configuration, initial center at Yogyakarta,
/// zoom clamping between [AppConstants.minZoom] and [AppConstants.maxZoom],
/// GeoJSON source and circle layer injection, feature tapping, and camera offset animation.
class MapViewWidget extends StatefulWidget {
  final IEnvConfig envConfig;
  final List<MapFeatureEntity> features;
  final MapFeatureEntity? selectedFeature;
  final UserLocationEntity? userLocation;
  final ValueChanged<MapFeatureEntity>? onFeatureTapped;
  final VoidCallback? onMapClick;
  final void Function(MapLibreMapController controller)? onMapCreated;
  final VoidCallback? onStyleLoaded;
  final Widget Function(BuildContext context)? customMapBuilder;

  const MapViewWidget({
    super.key,
    required this.envConfig,
    this.features = const [],
    this.selectedFeature,
    this.userLocation,
    this.onFeatureTapped,
    this.onMapClick,
    this.onMapCreated,
    this.onStyleLoaded,
    this.customMapBuilder,
  });

  @override
  State<MapViewWidget> createState() => MapViewWidgetState();
}

class MapViewWidgetState extends State<MapViewWidget> {
  MapLibreMapController? _controller;
  bool _isLayerAdded = false;
  bool _isSelectedFeatureLayerAdded = false;
  bool _isUserLocationLayerAdded = false;
  bool _isFeatureTapped = false;
  bool _isInjectingLayerData = false;
  bool _isInjectingSelectedFeature = false;
  bool _isInjectingUserLocation = false;
  Timer? _tapDebounceTimer;

  MapLibreMapController? get controller => _controller;

  @override
  void dispose() {
    _tapDebounceTimer?.cancel();
    _controller?.onFeatureTapped.remove(_handleFeatureTapped);
    _controller = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted || _controller == null) return;
    if (widget.features != oldWidget.features) {
      _injectLayerData();
    }
    if (widget.selectedFeature != oldWidget.selectedFeature) {
      _injectSelectedFeature();
    }
    if (widget.userLocation != oldWidget.userLocation) {
      _injectUserLocation();
      if (widget.userLocation != null) {
        animateCameraToUserLocation(widget.userLocation!);
      }
    }
  }

  void _handleMapCreated(MapLibreMapController controller) {
    if (!mounted) return;
    _controller = controller;
    widget.onMapCreated?.call(controller);

    controller.onFeatureTapped.add(_handleFeatureTapped);
  }

  Future<void> _handleStyleLoaded() async {
    widget.onStyleLoaded?.call();
    await _injectLayerData();
    if (widget.selectedFeature != null) {
      await _injectSelectedFeature();
    }
    if (widget.userLocation != null) {
      await _injectUserLocation();
    }
  }

  /// Injects GeoJSON source and vector circle layer into MapLibre with concurrency mutex guard (REQ-003, PRN-003).
  Future<void> _injectLayerData() async {
    final ctrl = _controller;
    if (!mounted || ctrl == null || widget.features.isEmpty) return;
    if (_isInjectingLayerData) return;
    _isInjectingLayerData = true;

    final geoJsonData = {
      'type': 'FeatureCollection',
      'features': widget.features.map((f) => {
        'type': 'Feature',
        'id': f.id,
        'geometry': {
          'type': 'Point',
          'coordinates': [f.longitude, f.latitude],
        },
        'properties': {
          'NAMA': f.name,
          'ALAMAT': f.address,
          'KECAMATAN': f.district,
          'WAKTU': f.recordTime,
        },
      }).toList(),
    };

    try {
      debugPrint(
        '[MapViewWidget] Injecting ${widget.features.length} GeoJSON feature(s) into MapLibre source...',
      );
      if (!_isLayerAdded) {
        await ctrl.addGeoJsonSource(
          AppConstants.geoJsonSourceId,
          geoJsonData,
        );
        if (!mounted || _controller == null) return;
        await ctrl.addCircleLayer(
          AppConstants.geoJsonSourceId,
          AppConstants.circleLayerId,
          const CircleLayerProperties(
            circleRadius: 7.5,
            circleColor: '#0284C7', // AppColors.mapPinDefault (Sky Blue 600 - Inactive POI)
            circleStrokeWidth: 1.5,
            circleStrokeColor: '#FFFFFF', // High-contrast border (antislop-ui)
            circleOpacity: 0.90,
          ),
          enableInteraction: true,
        );
        if (mounted && _controller != null) {
          setState(() {
            _isLayerAdded = true;
          });
          debugPrint(
            '[MapViewWidget] GeoJSON circle layer "${AppConstants.circleLayerId}" added to map successfully.',
          );
        }
      } else {
        if (!mounted || _controller == null) return;
        await ctrl.setGeoJsonSource(
          AppConstants.geoJsonSourceId,
          geoJsonData,
        );
        debugPrint(
          '[MapViewWidget] GeoJSON source "${AppConstants.geoJsonSourceId}" updated successfully.',
        );
      }
    } catch (e) {
      debugPrint('[MapViewWidget] Error injecting GeoJSON source/layer into MapLibre: $e');
    } finally {
      _isInjectingLayerData = false;
    }
  }

  /// Injects or updates user GPS location source and circle layer marker with concurrency mutex guard (REQ-005, PRN-003, ADR-0001).
  Future<void> _injectUserLocation() async {
    final ctrl = _controller;
    if (!mounted || ctrl == null) return;
    if (_isInjectingUserLocation) return;
    _isInjectingUserLocation = true;

    final List<Map<String, dynamic>> userFeatures = [];
    if (widget.userLocation != null) {
      userFeatures.add({
        'type': 'Feature',
        'id': 'user-location-marker',
        'geometry': {
          'type': 'Point',
          'coordinates': [
            widget.userLocation!.longitude,
            widget.userLocation!.latitude,
          ],
        },
        'properties': {
          'accuracy': widget.userLocation!.accuracy ?? 0.0,
        },
      });
    }

    final geoJsonData = {
      'type': 'FeatureCollection',
      'features': userFeatures,
    };

    try {
      if (!_isUserLocationLayerAdded) {
        await ctrl.addGeoJsonSource(
          AppConstants.userLocationSourceId,
          geoJsonData,
        );
        if (!mounted || _controller == null) return;
        // Outer halo / pulse circle
        await ctrl.addCircleLayer(
          AppConstants.userLocationSourceId,
          AppConstants.userLocationHaloLayerId,
          const CircleLayerProperties(
            circleRadius: 16.0,
            circleColor: '#38BDF8', // Sky Blue 400
            circleOpacity: 0.25,
            circleStrokeWidth: 1.0,
            circleStrokeColor: '#0284C7',
          ),
          enableInteraction: false,
        );
        if (!mounted || _controller == null) return;
        // Inner solid circle puck
        await ctrl.addCircleLayer(
          AppConstants.userLocationSourceId,
          AppConstants.userLocationCircleLayerId,
          const CircleLayerProperties(
            circleRadius: 8.0,
            circleColor: '#0284C7', // Sky Blue 600
            circleStrokeWidth: 2.5,
            circleStrokeColor: '#FFFFFF',
            circleOpacity: 1.0,
          ),
          enableInteraction: false,
        );
        if (mounted && _controller != null) {
          setState(() {
            _isUserLocationLayerAdded = true;
          });
        }
      } else {
        if (!mounted || _controller == null) return;
        await ctrl.setGeoJsonSource(
          AppConstants.userLocationSourceId,
          geoJsonData,
        );
      }
    } catch (e) {
      debugPrint('Notice: Error injecting User Location layer into MapLibre: $e');
    } finally {
      _isInjectingUserLocation = false;
    }
  }

  /// Injects or updates selected POI feature marker and halo ring with concurrency mutex guard (REQ-004, antislop-ui).
  Future<void> _injectSelectedFeature() async {
    final ctrl = _controller;
    if (!mounted || ctrl == null) return;
    if (_isInjectingSelectedFeature) return;
    _isInjectingSelectedFeature = true;

    final List<Map<String, dynamic>> selectedFeatures = [];
    if (widget.selectedFeature != null) {
      final f = widget.selectedFeature!;
      selectedFeatures.add({
        'type': 'Feature',
        'id': f.id,
        'geometry': {
          'type': 'Point',
          'coordinates': [f.longitude, f.latitude],
        },
        'properties': {
          'NAMA': f.name,
          'ALAMAT': f.address,
          'KECAMATAN': f.district,
          'WAKTU': f.recordTime,
        },
      });
    }

    final geoJsonData = {
      'type': 'FeatureCollection',
      'features': selectedFeatures,
    };

    try {
      if (!_isSelectedFeatureLayerAdded) {
        await ctrl.addGeoJsonSource(
          AppConstants.selectedFeatureSourceId,
          geoJsonData,
        );
        if (!mounted || _controller == null) return;

        // Outer focus halo / ring (antislop-ui: deliberate focus indicator, no endless pulsing)
        await ctrl.addCircleLayer(
          AppConstants.selectedFeatureSourceId,
          AppConstants.selectedFeatureHaloLayerId,
          const CircleLayerProperties(
            circleRadius: 16.0,
            circleColor: '#0284C7',
            circleOpacity: 0.20,
            circleStrokeWidth: 1.5,
            circleStrokeColor: '#1E3A8A', // Deep Royal Blue focus ring
          ),
        );
        if (!mounted || _controller == null) return;

        // Inner prominent active puck
        await ctrl.addCircleLayer(
          AppConstants.selectedFeatureSourceId,
          AppConstants.selectedFeatureCircleLayerId,
          const CircleLayerProperties(
            circleRadius: 10.0,
            circleColor: '#1E3A8A', // AppColors.primary (Deep Royal Blue)
            circleStrokeWidth: 2.5,
            circleStrokeColor: '#FFFFFF', // High-contrast border
            circleOpacity: 1.0,
          ),
        );
        if (mounted && _controller != null) {
          setState(() {
            _isSelectedFeatureLayerAdded = true;
          });
          debugPrint(
            '[MapViewWidget] Selected feature highlight layer added successfully.',
          );
        }
      } else {
        if (!mounted || _controller == null) return;
        await ctrl.setGeoJsonSource(
          AppConstants.selectedFeatureSourceId,
          geoJsonData,
        );
        debugPrint(
          '[MapViewWidget] Selected feature source updated (hasSelection: ${widget.selectedFeature != null}).',
        );
      }
    } catch (e) {
      debugPrint('[MapViewWidget] Error injecting selected feature layer: $e');
    } finally {
      _isInjectingSelectedFeature = false;
    }
  }


  /// Animates the camera to user location coordinates (REQ-005).
  void animateCameraToUserLocation(UserLocationEntity location) {
    final ctrl = _controller;
    if (!mounted || ctrl == null) return;

    try {
      ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          15.0,
        ),
      );
    } catch (e) {
      debugPrint('Notice: animateCameraToUserLocation failed: $e');
    }
  }

  /// Animates the camera back to Yogyakarta anchor coordinates with North-Up orientation (REQ-006).
  void animateCameraToYogyakarta() {
    final ctrl = _controller;
    if (!mounted || ctrl == null) return;

    try {
      ctrl.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(
              AppConstants.yogyakartaLatitude,
              AppConstants.yogyakartaLongitude,
            ),
            zoom: AppConstants.initialZoom,
            bearing: 0.0,
            tilt: 0.0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Notice: animateCameraToYogyakarta failed: $e');
    }
  }

  void _handleFeatureTapped(
    Point<double> point,
    LatLng coordinates,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    if (!mounted || _controller == null) return;
    // Guard: Only react to POI feature layer taps (ignore system or background taps)
    if (layerId != AppConstants.circleLayerId &&
        layerId != AppConstants.selectedFeatureCircleLayerId &&
        layerId != AppConstants.selectedFeatureHaloLayerId) {
      return;
    }

    _isFeatureTapped = true;
    _tapDebounceTimer?.cancel();
    _tapDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isFeatureTapped = false;
      }
    });

    MapFeatureEntity? matched;
    if (id.isNotEmpty) {
      matched = widget.features
          .where((f) => f.id == id || f.name == id)
          .firstOrNull;
    }

    matched ??= _findClosestFeature(coordinates.latitude, coordinates.longitude);

    if (matched != null && mounted) {
      widget.onFeatureTapped?.call(matched);
      animateCameraToFeature(matched);
    }
  }

  MapFeatureEntity? _findClosestFeature(double lat, double lon) {
    if (widget.features.isEmpty) return null;
    MapFeatureEntity? closest;
    double minDiff = double.infinity;
    for (final f in widget.features) {
      final diff = (f.latitude - lat).abs() + (f.longitude - lon).abs();
      if (diff < minDiff && diff < 0.05) {
        minDiff = diff;
        closest = f;
      }
    }
    return closest;
  }

  /// Animates the camera directly to the feature coordinate (REQ-004).
  void animateCameraToFeature(MapFeatureEntity feature) {
    final ctrl = _controller;
    if (!mounted || ctrl == null) return;

    try {
      final currentZoom = ctrl.cameraPosition?.zoom ?? AppConstants.initialZoom;
      final targetZoom = currentZoom < 14.0 ? 14.0 : currentZoom;

      ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(feature.latitude, feature.longitude),
          targetZoom,
        ),
      );
    } catch (e) {
      debugPrint('Notice: animateCameraToFeature failed: $e');
    }
  }

  void _handleMapClick(Point<double> point, LatLng coordinates) {
    if (!mounted || _isFeatureTapped) return;
    widget.onMapClick?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customMapBuilder != null) {
      return widget.customMapBuilder!(context);
    }

    return MapLibreMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(
          AppConstants.yogyakartaLatitude,
          AppConstants.yogyakartaLongitude,
        ),
        zoom: AppConstants.initialZoom,
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(
        AppConstants.minZoom,
        AppConstants.maxZoom,
      ),
      styleString: widget.envConfig.basemapStyleUrl,
      onMapCreated: _handleMapCreated,
      onStyleLoadedCallback: _handleStyleLoaded,
      onMapClick: _handleMapClick,
      myLocationEnabled: false, // On-demand tracking only per ADR-0001
      myLocationTrackingMode: MyLocationTrackingMode.none,
      trackCameraPosition: true,
      compassEnabled: true,
      compassViewPosition: CompassViewPosition.topRight,
      compassViewMargins: const Point(16, 76),
      attributionButtonMargins: const Point(-100, -100),
    );
  }
}
