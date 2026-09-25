import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/app_constants.dart';
import 'package:mapid/features/map/presentation/widgets/user_location_button.dart';

void main() {
  group('UserLocationButton Widget Tests', () {
    testWidgets('renders button with minimum 48x48 dp touch target (GUD-001, antislop-human)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserLocationButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonFinder = find.byKey(const Key('user_location_button'));
      expect(buttonFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.width, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
      expect(size.height, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
    });

    testWidgets('displays location icon when isLoading is false and triggers onPressed on tap', (tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserLocationButton(
              isLoading: false,
              onPressed: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byKey(const Key('user_location_button')));
      await tester.pump();

      expect(isTapped, isTrue);
    });

    testWidgets('displays CircularProgressIndicator when isLoading is true and ignores taps', (tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserLocationButton(
              isLoading: true,
              onPressed: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsNothing);

      await tester.tap(find.byKey(const Key('user_location_button')));
      await tester.pump();

      expect(isTapped, isFalse);
    });
  });
}
