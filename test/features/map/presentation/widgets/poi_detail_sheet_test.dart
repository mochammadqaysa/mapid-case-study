import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/app_constants.dart';
import 'package:mapid/features/map/domain/entities/map_feature_entity.dart';
import 'package:mapid/features/map/presentation/widgets/poi_detail_sheet.dart';

void main() {
  const sampleFeature = MapFeatureEntity(
    id: '1',
    name: 'Keraton Yogyakarta',
    address: 'Jl. Rotowijayan Blok No. 1, Panembahan, Kota Yogyakarta',
    district: 'Kraton',
    recordTime: '2024-09-24 08:00:00',
    latitude: -7.8003,
    longitude: 110.3672,
  );

  const fallbackFeature = MapFeatureEntity(
    id: '2',
    name: '-',
    address: '-',
    district: '-',
    recordTime: '-',
    latitude: 0.0,
    longitude: 0.0,
  );

  Widget createWidgetUnderTest({
    required MapFeatureEntity feature,
    required VoidCallback onClose,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: PoiDetailSheet(
            feature: feature,
            onClose: onClose,
          ),
        ),
      ),
    );
  }

  group('PoiDetailSheet Widget Tests', () {
    testWidgets('renders all feature properties accurately', (tester) async {
      var closed = false;
      await tester.pumpWidget(createWidgetUnderTest(
        feature: sampleFeature,
        onClose: () => closed = true,
      ));

      // Verify text elements
      expect(find.text('Keraton Yogyakarta'), findsOneWidget);
      expect(find.text('Kecamatan: Kraton'), findsOneWidget);
      expect(
        find.text('Jl. Rotowijayan Blok No. 1, Panembahan, Kota Yogyakarta'),
        findsOneWidget,
      );
      expect(find.text('Waktu: 2024-09-24 08:00:00'), findsOneWidget);
      expect(find.text('-7.8003, 110.3672'), findsOneWidget);

      // Verify Close Button exists and meets minimum 48x48 dp touch target (GUD-001)
      final closeButtonFinder = find.byKey(const Key('poi_detail_close_button'));
      expect(closeButtonFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(
        find.ancestor(
          of: closeButtonFinder,
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(renderBox.size.width, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
      expect(renderBox.size.height, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));

      // Tap close button
      await tester.tap(closeButtonFinder);
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('renders defensive fallback "-" without error (GUD-003)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        feature: fallbackFeature,
        onClose: () {},
      ));

      expect(find.text('-'), findsNWidgets(2)); // Name and Address
      expect(find.text('Kecamatan: -'), findsOneWidget);
      expect(find.text('Waktu: -'), findsOneWidget);
    });

    testWidgets('dismisses on downward drag gesture', (tester) async {
      var closed = false;
      await tester.pumpWidget(createWidgetUnderTest(
        feature: sampleFeature,
        onClose: () => closed = true,
      ));

      // Fling downward
      await tester.fling(
        find.byType(PoiDetailSheet),
        const Offset(0, 300),
        800,
      );
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });
  });
}
