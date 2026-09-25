import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/app_constants.dart';
import 'package:mapid/features/map/presentation/widgets/return_to_yogyakarta_chip.dart';

void main() {
  group('ReturnToYogyakartaChip Widget Tests', () {
    testWidgets('renders chip with label, icon, and meets minimum 48 dp height target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReturnToYogyakartaChip(
              onTap: () {},
            ),
          ),
        ),
      );

      final chipFinder = find.byKey(const Key('return_to_yogyakarta_chip'));
      expect(chipFinder, findsOneWidget);
      expect(find.text('Kembali ke Yogyakarta'), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);

      final size = tester.getSize(chipFinder);
      expect(size.height, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReturnToYogyakartaChip(
              onTap: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('return_to_yogyakarta_chip')));
      await tester.pump();

      expect(isTapped, isTrue);
    });
  });
}
