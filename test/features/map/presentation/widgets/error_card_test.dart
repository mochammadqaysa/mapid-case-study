import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/features/map/presentation/widgets/error_card.dart';

void main() {
  group('ErrorCard Widget Tests', () {
    testWidgets('renders error message, error icon, and retry button with semantic label',
        (WidgetTester tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ErrorCard(
                errorMessage: 'Gagal memuat layer GIS',
                onRetry: () => retryCalled = true,
              ),
            ),
          ),
        ),
      );

      // Verify text
      expect(find.text('Gagal memuat layer GIS'), findsOneWidget);

      // Verify error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Verify retry button & semantics
      final retryButton = find.byKey(const Key('map_error_retry_button'));
      expect(retryButton, findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Verify button tap
      await tester.tap(retryButton);
      await tester.pump();
      expect(retryCalled, isTrue);
    });

    testWidgets('retry button has minimum 48x48 dp tap target (WCAG AA & antislop)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ErrorCard(
                errorMessage: 'Terjadi kesalahan sistem',
                onRetry: () {},
              ),
            ),
          ),
        ),
      );

      final retryButton = find.byKey(const Key('map_error_retry_button'));
      final size = tester.getSize(retryButton);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('supports custom retryButtonKey if provided',
        (WidgetTester tester) async {
      const customKey = Key('custom_retry_key');
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ErrorCard(
                errorMessage: 'Custom error',
                retryButtonKey: customKey,
                onRetry: () => retryCalled = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(customKey), findsOneWidget);
      await tester.tap(find.byKey(customKey));
      expect(retryCalled, isTrue);
    });
  });
}
