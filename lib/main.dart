import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_colors.dart';
import 'features/map/presentation/pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables safely (SEC-001)
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('[Main] Successfully loaded .env file.');
  } catch (e) {
    debugPrint('[Main] Notice: .env file not found or failed to load ($e). Using compile-time defaults.');
  }

  final envConfig = EnvConfig();
  final hasApiKey = envConfig.mapidApiKey.isNotEmpty;
  final maskedKey = hasApiKey
      ? (envConfig.mapidApiKey.length > 6
          ? '${envConfig.mapidApiKey.substring(0, 4)}...${envConfig.mapidApiKey.substring(envConfig.mapidApiKey.length - 2)}'
          : '***')
      : '<EMPTY>';

  debugPrint(
    '[Main] EnvConfig initialized -> '
    'API_KEY: $maskedKey, '
    'LAYER_ID: "${envConfig.mapidLayerId}", '
    'PROJECT_ID: "${envConfig.mapidProjectId}", '
    'GEOSERVER_URL: "${envConfig.geoServerBaseUrl}"',
  );

  runApp(MapidApp(envConfig: envConfig));
}

/// Root widget for the MAPID Mobile GIS application.
class MapidApp extends StatelessWidget {
  final IEnvConfig envConfig;
  final Widget Function(BuildContext context)? customMapBuilder;

  const MapidApp({
    super.key,
    required this.envConfig,
    this.customMapBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mapid_case_study',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: MapPage(
        envConfig: envConfig,
        customMapBuilder: customMapBuilder,
      ),
    );
  }
}
