/// Functional error handling construct representing either a [Left] (Failure)
/// or a [Right] (Success).
abstract class Either<L, R> {
  const Either();

  /// Folds both branches into a single return value [B].
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => fold((l) => l, (_) => null);
  R? get rightOrNull => fold((_) => null, (r) => r);
}

/// Represents the failure branch of [Either].
class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) =>
      ifLeft(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Represents the success branch of [Either].
class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) =>
      ifRight(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
