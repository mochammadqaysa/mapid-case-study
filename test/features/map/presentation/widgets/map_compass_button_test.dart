import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/app_constants.dart';
import 'package:mapid/features/map/presentation/widgets/map_compass_button.dart';

void main() {
  group('MapCompassButton Widget Tests', () {
    testWidgets('renders visible and interactive when bearing is rotated',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapCompassButton(
              bearing: 45.0,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.byKey(const Key('map_compass_button'));
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      expect(pressed, isTrue);
    });

    testWidgets('is hidden (opacity 0 and ignored) when bearing is 0',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapCompassButton(
              bearing: 0.0,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final animatedOpacityFinder = find.byKey(const Key('map_compass_animated_opacity'));
      expect(animatedOpacityFinder, findsOneWidget);

      final animatedOpacity = tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(animatedOpacity.opacity, 0.0);

      final ignorePointerFinder = find.byKey(const Key('map_compass_ignore_pointer'));
      expect(ignorePointerFinder, findsOneWidget);
      final ignorePointer = tester.widget<IgnorePointer>(ignorePointerFinder);
      expect(ignorePointer.ignoring, isTrue);
    });

    testWidgets('meets minimum 48x48 dp touch target size (antislop-human)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapCompassButton(
              bearing: 90.0,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final renderBox = tester.renderObject<RenderBox>(
        find.byKey(const Key('map_compass_button')),
      );

      expect(renderBox.size.width, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
      expect(renderBox.size.height, greaterThanOrEqualTo(AppConstants.minTouchTargetSize));
    });
  });
}
