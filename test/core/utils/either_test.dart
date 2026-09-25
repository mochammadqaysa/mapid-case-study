import 'package:flutter_test/flutter_test.dart';
import 'package:mapid/core/utils/either.dart';

void main() {
  group('Either', () {
    test('Left returns left value on fold and handles equality', () {
      const Either<String, int> either = Left('Error');

      expect(either.isLeft, isTrue);
      expect(either.isRight, isFalse);
      expect(either.leftOrNull, 'Error');
      expect(either.rightOrNull, isNull);

      final result = either.fold(
        (l) => 'Failed with: $l',
        (r) => 'Success with: $r',
      );
      expect(result, 'Failed with: Error');
      expect(either, equals(const Left<String, int>('Error')));
    });

    test('Right returns right value on fold and handles equality', () {
      const Either<String, int> either = Right(42);

      expect(either.isLeft, isFalse);
      expect(either.isRight, isTrue);
      expect(either.leftOrNull, isNull);
      expect(either.rightOrNull, 42);

      final result = either.fold(
        (l) => 'Failed with: $l',
        (r) => 'Success with: $r',
      );
      expect(result, 'Success with: 42');
      expect(either, equals(const Right<String, int>(42)));
    });
  });
}
