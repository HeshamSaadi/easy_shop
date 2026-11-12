import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/core/databases/cache/token_storage.dart';
import 'package:easy_shop/features/client/auth/data/datasources/auth_remote_data_source.dart';

/// Hand-written fake: set [error] to make every call throw it,
/// and read the recorded arguments to check what the repository sent.
class FakeClientAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeClientAuthRemoteDataSource([this.log]);

  /// Shared with the other fakes, so a test can check the order of calls.
  final List<String>? log;

  Object? error;
  String token = 'jwt-token';

  final List<
    ({
      String name,
      String email,
      String phone,
      String password,
      String passwordConfirmation,
      String? address,
      double? latitude,
      double? longitude,
      String? picturePath,
    })
  >
  registerArgs = [];
  final List<({String email, String password})> loginArgs = [];
  final List<({String email, String otpCode})> verifyArgs = [];
  final List<String> resendArgs = [];
  int logoutCalls = 0;

  void _throwIfNeeded() {
    final failure = error;
    if (failure != null) throw failure;
  }

  @override
  Future<void> register({
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
    _throwIfNeeded();
  }

  @override
  Future<void> login({required String email, required String password}) async {
    loginArgs.add((email: email, password: password));
    _throwIfNeeded();
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    verifyArgs.add((email: email, otpCode: otpCode));
    log?.add('remote.verifyOtp');
    _throwIfNeeded();
    return token;
  }

  @override
  Future<void> resendOtp({required String email}) async {
    resendArgs.add(email);
    _throwIfNeeded();
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    log?.add('remote.logout');
    _throwIfNeeded();
  }
}

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this.log]);

  final List<String>? log;

  String? token;
  Object? saveError;

  final List<String> savedTokens = [];
  int clearCalls = 0;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> saveToken(String value) async {
    log?.add('storage.saveToken');
    final failure = saveError;
    if (failure != null) throw failure;
    savedTokens.add(value);
    token = value;
  }

  @override
  Future<void> clearToken() async {
    log?.add('storage.clearToken');
    clearCalls++;
    token = null;
  }
}

/// The real [SessionEvents] with a counter on [reset].
class RecordingSessionEvents extends SessionEvents {
  RecordingSessionEvents([this.log]);

  final List<String>? log;
  int resetCalls = 0;

  @override
  void reset() {
    log?.add('events.reset');
    resetCalls++;
    super.reset();
  }
}
