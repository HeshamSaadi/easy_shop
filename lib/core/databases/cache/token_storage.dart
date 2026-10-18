abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> clearToken();
}
