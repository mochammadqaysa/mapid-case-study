import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/errors/failures.dart';

void main() {
  group('Failures', () {
    test('ServerFailure supports value equality and custom statusCode', () {
      const failure1 = ServerFailure('Internal Error', 500);
      const failure2 = ServerFailure('Internal Error', 500);
      const failure3 = ServerFailure('Not Found', 404);

      expect(failure1, equals(failure2));
      expect(failure1.hashCode, equals(failure2.hashCode));
      expect(failure1, isNot(equals(failure3)));
      expect(failure1.statusCode, 500);
    });

    test('NetworkFailure supports value equality', () {
      const failure1 = NetworkFailure('No Internet');
      const failure2 = NetworkFailure('No Internet');
      const failure3 = NetworkFailure('Timeout');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('LocationPermissionFailure supports isPermanentlyDenied flag', () {
      const failure1 = LocationPermissionFailure('Denied', isPermanentlyDenied: true);
      const failure2 = LocationPermissionFailure('Denied', isPermanentlyDenied: true);
      const failure3 = LocationPermissionFailure('Denied', isPermanentlyDenied: false);

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
      expect(failure1.isPermanentlyDenied, isTrue);
    });
  });
}
