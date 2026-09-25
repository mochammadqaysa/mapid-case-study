import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

    try {
      final response = await client.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        if (decodedBody is! Map<String, dynamic>) {
          throw const ServerException('Invalid GeoJSON response format.');
        }
        return LayerResponseModel.fromJson(decodedBody);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw ServerException(
          'Invalid API key or unauthorized project access.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw const ServerException(
          'Layer or project not found.',
          statusCode: 404,
        );
      } else {
        throw ServerException(
          'Failed to fetch layer data: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException('No internet connection: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timeout while fetching layer data.');
    } on http.ClientException catch (e) {
      throw NetworkException('Network client error: ${e.message}');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
