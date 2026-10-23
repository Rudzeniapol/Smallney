import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'dto.dart';

/// What the sync engine needs from the server (faked in tests).
abstract interface class SyncApi {
  Future<PushResponseDto> push(List<SyncChangeDto> changes);

  Future<PullResponseDto> pull(int since, {int limit = 500});

  Future<RatesResponseDto> rates();
}

/// Typed access to the REST API. Every failure surfaces as [ApiException].
class ApiClient implements SyncApi {
  ApiClient(this._dio);

  final Dio _dio;

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? baseCurrency,
    int? firstDayOfMonth,
    String? timezone,
  }) =>
      _call(() => _dio.post<Map<String, dynamic>>('/api/v1/auth/register', data: {
            'email': email,
            'password': password,
            'baseCurrency': ?baseCurrency,
            'firstDayOfMonth': ?firstDayOfMonth,
            'timezone': ?timezone,
          }), AuthResponse.fromJson);

  Future<AuthResponse> login(String email, String password) => _call(
      () => _dio.post<Map<String, dynamic>>('/api/v1/auth/login', data: {'email': email, 'password': password}),
      AuthResponse.fromJson);

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>('/api/v1/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException {
      // Logging out locally must work offline too.
    }
  }

  Future<MeResponse> me() => _call(() => _dio.get<Map<String, dynamic>>('/api/v1/me'), MeResponse.fromJson);

  Future<MeResponse> updateMe(Map<String, dynamic> patch) =>
      _call(() => _dio.patch<Map<String, dynamic>>('/api/v1/me', data: patch), MeResponse.fromJson);

  @override
  Future<PushResponseDto> push(List<SyncChangeDto> changes) => _call(
      () => _dio.post<Map<String, dynamic>>('/api/v1/sync/push', data: {'changes': changes.map((c) => c.toJson()).toList()}),
      PushResponseDto.fromJson);

  @override
  Future<PullResponseDto> pull(int since, {int limit = 500}) => _call(
      () => _dio.get<Map<String, dynamic>>('/api/v1/sync/pull', queryParameters: {'since': since, 'limit': limit}),
      PullResponseDto.fromJson);

  @override
  Future<RatesResponseDto> rates() =>
      _call(() => _dio.get<Map<String, dynamic>>('/api/v1/rates'), RatesResponseDto.fromJson);

  Future<T> _call<T>(Future<Response<Map<String, dynamic>>> Function() request, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await request();
      return parse(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
