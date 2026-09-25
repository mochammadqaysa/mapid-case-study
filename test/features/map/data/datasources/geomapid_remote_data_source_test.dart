import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:mapid/core/config/env_config.dart';
import 'package:mapid/core/errors/exceptions.dart';
import 'package:mapid/features/map/data/datasources/geomapid_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late IEnvConfig fakeEnv;
  late GeoMapidRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    fakeEnv = EnvConfig({
      'MAPID_API_KEY': 'test_api_key',
      'MAPID_LAYER_ID': 'test_layer_id',
      'MAPID_PROJECT_ID': 'test_project_id',
      'MAPID_GEOSERVER_URL': 'https://geoserver.mapid.io/layers_new/get_layer',
    });
    dataSource = GeoMapidRemoteDataSource(
      client: mockClient,
      envConfig: fakeEnv,
    );
  });

  group('GeoMapidRemoteDataSource Tests', () {
    const validResponseJson = '''
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [110.3672, -7.8003]
          },
          "properties": {
            "NAMA": "Keraton Yogyakarta",
            "ALAMAT": "Jl. Rotowijayan",
            "KECAMATAN": "Kraton",
            "WAKTU": "2024-09-24"
          }
        }
      ]
    }
    ''';

    test('should return LayerResponseModel when HTTP response is 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(validResponseJson, 200));

      final result = await dataSource.getLayerData();

      expect(result.features.length, 1);
      expect(result.features.first.properties.name, 'Keraton Yogyakarta');
      verify(() => mockClient.get(
            any(that: predicate<Uri>((uri) {
              return uri.queryParameters['api_key'] == 'test_api_key' &&
                  uri.queryParameters['layer_id'] == 'test_layer_id' &&
                  uri.queryParameters['project_id'] == 'test_project_id';
            })),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should throw ServerException when status code is 401/403', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{"status":"error"}', 401));

      expect(
        () => dataSource.getLayerData(),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('should throw ServerException when status code is 404', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => dataSource.getLayerData(),
        throwsA(isA<ServerException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('should throw NetworkException on SocketException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SocketException('Failed host lookup'));

      expect(
        () => dataSource.getLayerData(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
