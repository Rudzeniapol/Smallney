import 'dart:async';

import 'package:dio/dio.dart';

import '../api/dto.dart';
import 'token_store.dart';

/// Keeps the current tokens and refreshes them one at a time: the server rotates refresh tokens and
/// treats a reused one as theft (docs/decisions.md, D16), so parallel refreshes must never happen.
class TokenManager {
  TokenManager(this._store, this._refreshDio, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final TokenStore _store;

  /// A Dio without the auth interceptor, used only for /auth/refresh.
  final Dio _refreshDio;
  final DateTime Function() _now;

  Tokens? _tokens;
  bool _loaded = false;
  Future<bool>? _refreshing;

  /// Called when the session cannot be refreshed any more.
  void Function()? onExpired;

  Future<Tokens?> current() async {
    if (!_loaded) {
      _tokens = await _store.read();
      _loaded = true;
    }
    return _tokens;
  }

  Future<void> save(AuthResponse auth) async {
    _tokens = Tokens(
      accessToken: auth.accessToken,
      accessTokenExpiresAt: auth.accessTokenExpiresAt.toUtc(),
      refreshToken: auth.refreshToken,
      userId: auth.userId,
    );
    _loaded = true;
    await _store.write(_tokens!);
  }

  Future<void> clear() async {
    _tokens = null;
    _loaded = true;
    await _store.clear();
  }

  /// An access token valid for at least 30 more seconds, refreshing first if needed.
  Future<String?> validAccessToken() async {
    final tokens = await current();
    if (tokens == null) return null;
    if (tokens.accessTokenExpiresAt.isAfter(_now().toUtc().add(const Duration(seconds: 30)))) {
      return tokens.accessToken;
    }
    return await refresh() ? _tokens?.accessToken : null;
  }

  /// Single-flight refresh: concurrent callers await the same request.
  Future<bool> refresh() => _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final tokens = await current();
    if (tokens == null) return false;
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>('/api/v1/auth/refresh', data: {'refreshToken': tokens.refreshToken});
      await save(AuthResponse.fromJson(response.data!));
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await clear();
        onExpired?.call();
      }
      return false;
    }
  }
}

/// Adds the bearer token and retries once after a refresh when the server answers 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._dio);

  final TokenManager _tokens;
  final Dio _dio;

  static const _retried = 'auth_retried';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.contains('/auth/')) {
      final token = await _tokens.validAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || request.path.contains('/auth/') || request.extra[_retried] == true) {
      return handler.next(err);
    }

    if (!await _tokens.refresh()) return handler.next(err);
    try {
      final token = (await _tokens.current())?.accessToken;
      request.headers['Authorization'] = 'Bearer $token';
      request.extra[_retried] = true;
      handler.resolve(await _dio.fetch(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
