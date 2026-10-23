import 'package:dio/dio.dart';

/// A failed API call. [code] is the server's stable ProblemDetails code (or "network" / "unknown").
class ApiException implements Exception {
  const ApiException(this.code, this.message, {this.status, this.fieldErrors = const {}});

  final String code;
  final String message;
  final int? status;
  final Map<String, List<String>> fieldErrors;

  bool get isNetwork => code == 'network';

  bool get isUnauthorized => status == 401;

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) {
      return ApiException('network', e.message ?? 'Network error');
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final errors = <String, List<String>>{};
      if (data['errors'] case final Map<String, dynamic> map) {
        map.forEach((key, value) => errors[key] = (value as List).map((v) => '$v').toList());
      }
      return ApiException(
        (data['code'] as String?) ?? 'http_${response.statusCode}',
        (data['detail'] as String?) ?? (data['title'] as String?) ?? 'Request failed',
        status: response.statusCode,
        fieldErrors: errors,
      );
    }

    return ApiException('http_${response.statusCode}', 'Request failed', status: response.statusCode);
  }

  @override
  String toString() => 'ApiException($code, $status): $message';
}
