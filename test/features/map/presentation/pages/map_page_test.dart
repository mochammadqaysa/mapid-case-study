import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/config/env_config.dart';
import 'package:mapid/core/errors/failures.dart';
import 'package:mapid/features/map/domain/entities/map_feature_entity.dart';
import 'package:mapid/features/map/presentation/cubit/map_cubit.dart';
import 'package:mapid/features/map/presentation/cubit/map_state.dart';
import 'package:mapid/features/map/presentation/pages/map_page.dart';
import 'package:mapid/features/map/presentation/widgets/map_view_widget.dart';
import 'package:mapid/features/map/presentation/widgets/poi_detail_sheet.dart';
import 'package:mapid/features/map/presentation/widgets/return_to_yogyakarta_chip.dart';
import 'package:mapid/features/map/presentation/widgets/user_location_button.dart';

class MockMapCubit extends MockCubit<MapState> implements MapCubit {}

void main() {
  late IEnvConfig mockEnvConfig;
  late MockMapCubit mockMapCubit;

  const sampleFeature = MapFeatureEntity(
    id: '1',
    name: 'Keraton Yogyakarta',
    address: 'Jl. Rotowijayan Blok No. 1',
    district: 'Kraton',
    recordTime: '2024-09-24',
    latitude: -7.8003,
    longitude: 110.3672,
  );

  setUp(() {
    mockEnvConfig = EnvConfig({
      'MAPID_API_KEY': 'test_key',
      'MAPID_LAYER_ID': 'test_layer',
      'MAPID_PROJECT_ID': 'test_project',
    });
    mockMapCubit = MockMapCubit();
  });

  Widget createWidgetUnderTest({
    MapCubit? cubit,
    Widget Function(BuildContext context)? customMapBuilder,
  }) {
    return MaterialApp(
      home: MapPage(
        envConfig: mockEnvConfig,
        cubit: cubit,
        customMapBuilder: customMapBuilder ??
            (context) => Container(
                  key: const Key('mock_map_surface'),
                  color: Colors.blueGrey,
                ),
      ),
    );
  }

  group('MapPage Widget Tests', () {
    testWidgets('renders title, status indicator, and attribution badge',
        (WidgetTester tester) async {
      when(() => mockMapCubit.state).thenReturn(const MapState());

      await tester.pumpWidget(createWidgetUnderTest(cubit: mockMapCubit));

      // Verify Title
      expect(find.text('MAPID Mobile GIS'), findsOneWidget);

      // Verify Initial Status text
      expect(find.text('Loading Basemap...'), findsOneWidget);

      // Verify Attribution Badge
      expect(find.text('© OpenFreeMap • © OpenStreetMap'), findsOneWidget);

      // Verify MapViewWidget exists in tree
      expect(find.byType(MapViewWidget), findsOneWidget);
      expect(find.byKey(const Key('mock_map_surface')), findsOneWidget);
    });

    testWidgets('renders custom map builder when provided',
        (WidgetTester tester) async {
      when(() => mockMapCubit.state).thenReturn(const MapState());

      await tester.pumpWidget(
        createWidgetUnderTest(
          cubit: mockMapCubit,
          customMapBuilder: (context) => const Center(
            child: Text('Custom Map Canvas'),
          ),
        ),
      );

      expect(find.text('Custom Map Canvas'), findsOneWidget);
    });

    testWidgets('renders PoiDetailSheet when selectedFeature is present',
        (WidgetTester tester) async {
      when(() => mockMapCubit.state).thenReturn(
        const MapState(
          status: MapStatus.loaded,
          features: [sampleFeature],
          selectedFeature: sampleFeature,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(cubit: mockMapCubit));

      expect(find.byType(PoiDetailSheet), findsOneWidget);
      expect(find.text('Keraton Yogyakarta'), findsOneWidget);

      // Tap close button on sheet
      final closeButton = find.byKey(const Key('poi_detail_close_button'));
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pump();

      verify(() => mockMapCubit.clearSelectedFeature()).called(1);
    });

    testWidgets('renders error banner and triggers retry on button tap (REQ-007, AC-007)',
        (WidgetTester tester) async {
      when(() => mockMapCubit.state).thenReturn(
        const MapState(
          status: MapStatus.failure,
          errorMessage: 'Koneksi jaringan terputus',
        ),
      );
      when(() => mockMapCubit.loadLayerData()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(cubit: mockMapCubit));

      expect(find.text('Koneksi jaringan terputus'), findsOneWidget);
      final retryButton = find.byKey(const Key('map_error_retry_button'));
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      verify(() => mockMapCubit.loadLayerData()).called(1);
    });

    testWidgets('renders UserLocationButton and triggers getUserLocation on tap (REQ-005)',
        (WidgetTester tester) async {
      when(() => mockMapCubit.state).thenReturn(const MapState());
      when(() => mockMapCubit.getUserLocation()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(cubit: mockMapCubit));

      final buttonFinder = find.byType(UserLocationButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();

      verify(() => mockMapCubit.getUserLocation()).called(1);
    });

    testWidgets('renders ReturnToYogyakartaChip when showYogyakartaReturnChip is true and recenters on tap (REQ-006)',
        (WidgetTester tester) async {
      when(() => mockMapCubit.state).thenReturn(
        const MapState(showYogyakartaReturnChip: true),
      );
      when(() => mockMapCubit.recenterToYogyakarta()).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest(cubit: mockMapCubit));

      final chipFinder = find.byType(ReturnToYogyakartaChip);
      expect(chipFinder, findsOneWidget);
      expect(find.text('Kembali ke Yogyakarta'), findsOneWidget);

      await tester.tap(chipFinder);
      await tester.pump();

      verify(() => mockMapCubit.recenterToYogyakarta()).called(1);
    });

    testWidgets('displays SnackBar when locationFailure is emitted (AC-006, TASK-016)',
        (WidgetTester tester) async {
      whenListen(
        mockMapCubit,
        Stream.fromIterable([
          const MapState(
            locationFailure: LocationPermissionFailure('Izin lokasi ditolak pengguna'),
          ),
        ]),
        initialState: const MapState(),
      );
      when(() => mockMapCubit.clearLocationFailure()).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest(cubit: mockMapCubit));
      await tester.pump(); // Process stream

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Izin lokasi ditolak pengguna'), findsOneWidget);
      verify(() => mockMapCubit.clearLocationFailure()).called(1);
    });
  });
}
