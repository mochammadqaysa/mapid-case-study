import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/config/env_config.dart';
import 'package:mapid/features/map/presentation/pages/map_page.dart';
import 'package:mapid/main.dart';

void main() {
  testWidgets('MapidApp smoke test loads MapPage', (WidgetTester tester) async {
    final envConfig = EnvConfig({
      'MAPID_API_KEY': 'smoke_test_key',
    });

    await tester.pumpWidget(
      MapidApp(
        envConfig: envConfig,
        customMapBuilder: (context) => const SizedBox(key: Key('smoke_test_map')),
      ),
    );

    expect(find.byType(MapPage), findsOneWidget);
    expect(find.text('MAPID Mobile GIS'), findsOneWidget);
  });
}
