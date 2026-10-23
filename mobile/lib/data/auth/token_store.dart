import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens {
  const Tokens({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.userId,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final String userId;
}

/// Where tokens live between launches.
abstract interface class TokenStore {
  Future<Tokens?> read();

  Future<void> write(Tokens tokens);

  Future<void> clear();
}

/// Keychain / Keystore backed storage.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _access = 'access_token';
  static const _accessExpires = 'access_token_expires_at';
  static const _refresh = 'refresh_token';
  static const _user = 'user_id';

  @override
  Future<Tokens?> read() async {
    final values = await _storage.readAll();
    final access = values[_access];
    final refresh = values[_refresh];
    final user = values[_user];
    final expires = DateTime.tryParse(values[_accessExpires] ?? '');
    if (access == null || refresh == null || user == null || expires == null) return null;
    return Tokens(accessToken: access, accessTokenExpiresAt: expires, refreshToken: refresh, userId: user);
  }

  @override
  Future<void> write(Tokens tokens) async {
    await _storage.write(key: _access, value: tokens.accessToken);
    await _storage.write(key: _accessExpires, value: tokens.accessTokenExpiresAt.toUtc().toIso8601String());
    await _storage.write(key: _refresh, value: tokens.refreshToken);
    await _storage.write(key: _user, value: tokens.userId);
  }

  @override
  Future<void> clear() => _storage.deleteAll();
}

class MemoryTokenStore implements TokenStore {
  Tokens? _tokens;

  @override
  Future<Tokens?> read() async => _tokens;

  @override
  Future<void> write(Tokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
