import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';

/// Runs a data source call and turns any exception into a [Failure].
/// Every repository implementation uses this, so the try/catch lives once.
Future<Either<Failure, T>> guardedCall<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on AppException catch (e) {
    return Left(Failure.fromException(e));
  } catch (_) {
    return Left(Failure.fromException(const UnknownException()));
  }
}
