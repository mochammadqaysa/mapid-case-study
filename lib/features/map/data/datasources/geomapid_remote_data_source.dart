import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/geojson_feature_model.dart';

/// Contract for GEO MAPID remote data source.
abstract class IGeoMapidRemoteDataSource {
  Future<LayerResponseModel> getLayerData();
}

/// Implementation of [IGeoMapidRemoteDataSource] using [http.Client] (REQ-002, SEC-001).
class GeoMapidRemoteDataSource implements IGeoMapidRemoteDataSource {
  final http.Client client;
  final IEnvConfig envConfig;

  const GeoMapidRemoteDataSource({
    required this.client,
    required this.envConfig,
  });

  @override
  Future<LayerResponseModel> getLayerData() async {
    final uri = Uri.parse(envConfig.geoServerBaseUrl).replace(
      queryParameters: {
        'api_key': envConfig.mapidApiKey,
        'layer_id': envConfig.mapidLayerId,
        'project_id': envConfig.mapidProjectId,
      },
    );

    final hasApiKey = envConfig.mapidApiKey.isNotEmpty;
    final maskedKey = hasApiKey
        ? (envConfig.mapidApiKey.length > 4
            ? '${envConfig.mapidApiKey.substring(0, 4)}***'
            : '***')
        : '<EMPTY>';

    debugPrint('[GeoMapidRemoteDataSource] Fetching layer data: $uri');
    debugPrint(
      '[GeoMapidRemoteDataSource] Parameters -> '
      'layer_id="${envConfig.mapidLayerId}", '
      'project_id="${envConfig.mapidProjectId}", '
      'api_key=$maskedKey',
    );

    try {
      final response = await client.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[GeoMapidRemoteDataSource] HTTP Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        if (decodedBody is! Map<String, dynamic>) {
          debugPrint(
            '[GeoMapidRemoteDataSource] Malformed GeoJSON response (not a JSON Object): ${response.body}',
          );
          throw const ServerException('Invalid GeoJSON response format.');
        }
        final model = LayerResponseModel.fromJson(decodedBody);
        debugPrint(
          '[GeoMapidRemoteDataSource] Successfully loaded and parsed ${model.features.length} GeoJSON feature(s).',
        );
        return model;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint(
          '[GeoMapidRemoteDataSource] Auth Failure (${response.statusCode}): ${response.body}. '
          'Please verify MAPID_API_KEY in your .env or --dart-define has access to project "${envConfig.mapidProjectId}".',
        );
        throw ServerException(
          'Invalid API key or unauthorized project access.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        debugPrint(
          '[GeoMapidRemoteDataSource] Not Found (404): ${response.body}. '
          'Please verify MAPID_LAYER_ID="${envConfig.mapidLayerId}" and MAPID_PROJECT_ID="${envConfig.mapidProjectId}".',
        );
        throw const ServerException(
          'Layer or project not found.',
          statusCode: 404,
        );
      } else {
        debugPrint(
          '[GeoMapidRemoteDataSource] Server Error (${response.statusCode}): ${response.body}',
        );
        throw ServerException(
          'Failed to fetch layer data: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      debugPrint('[GeoMapidRemoteDataSource] SocketException: ${e.message} (osError: ${e.osError})');
      throw NetworkException('No internet connection: ${e.message}');
    } on TimeoutException {
      debugPrint('[GeoMapidRemoteDataSource] TimeoutException: Connection timed out after 15 seconds.');
      throw const NetworkException('Connection timeout while fetching layer data.');
    } on http.ClientException catch (e) {
      debugPrint('[GeoMapidRemoteDataSource] ClientException: ${e.message} (uri: ${e.uri})');
      throw NetworkException('Network client error: ${e.message}');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e, stack) {
      debugPrint('[GeoMapidRemoteDataSource] Unexpected Exception: $e\n$stack');
      throw ServerException('Unexpected error: $e');
    }
  }
}
