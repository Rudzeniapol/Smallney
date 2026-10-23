import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smallney/data/api/dto.dart';
import 'package:smallney/data/auth/token_manager.dart';
import 'package:smallney/data/auth/token_store.dart';

/// Answers /auth/refresh after a short delay and counts the calls.
class _RefreshServer implements HttpClientAdapter {
  int refreshCalls = 0;
  int status = 200;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (status != 200) return ResponseBody.fromString('{"code":"invalid_refresh_token"}', status, headers: _json);
    return ResponseBody.fromString(
      jsonEncode({
        'accessToken': 'access-$refreshCalls',
        'accessTokenExpiresAt': DateTime.now().toUtc().add(const Duration(minutes: 15)).toIso8601String(),
        'refreshToken': 'refresh-$refreshCalls',
        'refreshTokenExpiresAt': DateTime.now().toUtc().add(const Duration(days: 30)).toIso8601String(),
        'userId': 'user-1',
      }),
      200,
      headers: _json,
    );
  }

  static final _json = {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  };

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RefreshServer server;
  late MemoryTokenStore store;
  late TokenManager tokens;

  setUp(() async {
    server = _RefreshServer();
    store = MemoryTokenStore();
    tokens = TokenManager(store, Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = server);
    await tokens.save(AuthResponse(
      accessToken: 'expired',
      accessTokenExpiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      refreshToken: 'refresh-0',
      refreshTokenExpiresAt: DateTime.now().toUtc().add(const Duration(days: 30)),
      userId: 'user-1',
    ));
  });

  test('parallel callers share a single refresh', () async {
    final results = await Future.wait(List.generate(5, (_) => tokens.validAccessToken()));

    expect(server.refreshCalls, 1, reason: 'the server rotates refresh tokens; a second refresh would log the user out');
    expect(results.toSet(), {'access-1'});
    expect((await store.read())!.refreshToken, 'refresh-1');
  });

  test('a valid token is used without refreshing', () async {
    await tokens.validAccessToken();
    await tokens.validAccessToken();
    expect(server.refreshCalls, 1);
  });

  test('a rejected refresh clears the session and reports expiry', () async {
    var expired = false;
    tokens.onExpired = () => expired = true;
    server.status = 401;

    expect(await tokens.validAccessToken(), isNull);
    expect(expired, isTrue);
    expect(await store.read(), isNull);
  });
}
