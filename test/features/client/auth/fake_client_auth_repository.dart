import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

typedef RegisterArgs = ({
  String name,
  String email,
  String phone,
  String password,
  String passwordConfirmation,
  String? address,
  double? latitude,
  double? longitude,
  String? picturePath,
});

/// Hand-written fake for the Client auth repository.
/// Set a `*Result` to control what a call returns,
/// and read the `*Args` lists to check what the use case sent.
class FakeClientAuthRepository implements AuthRepository {
  FakeClientAuthRepository({bool hasSession = false})
    : sessionResult = hasSession;

  bool sessionResult;

  Either<Failure, Unit> registerResult = const Right(unit);
  Either<Failure, Unit> loginResult = const Right(unit);
  Either<Failure, Unit> verifyResult = const Right(unit);
  Either<Failure, Unit> resendResult = const Right(unit);
  Either<Failure, Unit> logoutResult = const Right(unit);

  final List<RegisterArgs> registerArgs = [];
  final List<({String email, String password})> loginArgs = [];
  final List<({String email, String otpCode})> verifyArgs = [];
  final List<String> resendArgs = [];
  int logoutCalls = 0;

  @override
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    registerArgs.add((
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      address: address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
    ));
    return registerResult;
  }

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    loginArgs.add((email: email, password: password));
    return loginResult;
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    verifyArgs.add((email: email, otpCode: otpCode));
    return verifyResult;
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async {
    resendArgs.add(email);
    return resendResult;
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return logoutResult;
  }

  @override
  Future<bool> hasValidSession() async => sessionResult;
}
