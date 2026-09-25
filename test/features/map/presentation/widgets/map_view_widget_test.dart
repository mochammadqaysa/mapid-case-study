import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/env_config.dart';
import 'package:mapid/features/map/domain/entities/map_feature_entity.dart';
import 'package:mapid/features/map/presentation/widgets/map_view_widget.dart';

class MockEnvConfig implements IEnvConfig {
  @override
  String get mapidApiKey => 'test-api-key';

  @override
  String get mapidLayerId => 'test-layer-id';

  @override
  String get mapidProjectId => 'test-project-id';

  @override
  String get geoServerBaseUrl => 'https://mock.geoserver.io';

  @override
  String get basemapStyleUrl => 'https://mock.tiles.org/style';
}

void main() {
  const sampleFeature1 = MapFeatureEntity(
    id: 'feature-1',
    name: 'Keraton Yogyakarta',
    address: 'Jl. Rotowijayan Blok No. 1',
    district: 'Kraton',
    recordTime: '2026-09-24 08:30:00',
    latitude: -7.8053,
    longitude: 110.3642,
  );

  const sampleFeature2 = MapFeatureEntity(
    id: 'feature-2',
    name: 'Tugu Pal Putih',
    address: 'Jl. Jend. Sudirman',
    district: 'Jetis',
    recordTime: '2026-09-24 09:00:00',
    latitude: -7.7828,
    longitude: 110.3670,
  );

  group('MapViewWidget Widget Tests', () {
    testWidgets('renders customMapBuilder and binds selectedFeature correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapViewWidget(
              envConfig: MockEnvConfig(),
              features: const [sampleFeature1, sampleFeature2],
              selectedFeature: sampleFeature1,
              customMapBuilder: (context) => Container(
                key: const Key('custom_map_builder_canvas'),
                child: const Text('Map Canvas with Active Marker'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MapViewWidget), findsOneWidget);
      expect(find.byKey(const Key('custom_map_builder_canvas')), findsOneWidget);
      expect(find.text('Map Canvas with Active Marker'), findsOneWidget);

      final widgetFinder = find.byType(MapViewWidget);
      final mapView = tester.widget<MapViewWidget>(widgetFinder);

      expect(mapView.features.length, 2);
      expect(mapView.selectedFeature, equals(sampleFeature1));
      expect(mapView.selectedFeature?.name, 'Keraton Yogyakarta');
    });

    testWidgets('updates selectedFeature on widget update',
        (WidgetTester tester) async {
      MapFeatureEntity? currentSelected = sampleFeature1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      key: const Key('select_feature_2_btn'),
                      onPressed: () {
                        setState(() {
                          currentSelected = sampleFeature2;
                        });
                      },
                      child: const Text('Select Feature 2'),
                    ),
                    ElevatedButton(
                      key: const Key('clear_selection_btn'),
                      onPressed: () {
                        setState(() {
                          currentSelected = null;
                        });
                      },
                      child: const Text('Clear Selection'),
                    ),
                    Expanded(
                      child: MapViewWidget(
                        envConfig: MockEnvConfig(),
                        features: const [sampleFeature1, sampleFeature2],
                        selectedFeature: currentSelected,
                        customMapBuilder: (context) => Container(
                          key: const Key('map_canvas'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      var mapView = tester.widget<MapViewWidget>(find.byType(MapViewWidget));
      expect(mapView.selectedFeature, equals(sampleFeature1));

      // Switch selection to Feature 2
      await tester.tap(find.byKey(const Key('select_feature_2_btn')));
      await tester.pump();

      mapView = tester.widget<MapViewWidget>(find.byType(MapViewWidget));
      expect(mapView.selectedFeature, equals(sampleFeature2));

      // Clear selection
      await tester.tap(find.byKey(const Key('clear_selection_btn')));
      await tester.pump();

      mapView = tester.widget<MapViewWidget>(find.byType(MapViewWidget));
      expect(mapView.selectedFeature, isNull);
    });
  });
}
