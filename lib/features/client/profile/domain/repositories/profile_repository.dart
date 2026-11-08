import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';

/// Repository interface for client profile operations.
abstract class ProfileRepository {
  /// Retrieves the current authenticated client's profile information.
  ///
  /// Returns [ClientEntity] on success, or [Failure] on error.
  Future<Either<Failure, ClientEntity>> getProfile();

  /// Updates the current authenticated client's profile information.
  ///
  /// Returns updated [ClientEntity] on success, or [Failure] on error.
  Future<Either<Failure, ClientEntity>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  });
}
