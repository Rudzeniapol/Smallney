import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required DateTime accessTokenExpiresAt,
    required String refreshToken,
    required DateTime refreshTokenExpiresAt,
    required String userId,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@freezed
abstract class MeResponse with _$MeResponse {
  const factory MeResponse({
    required String id,
    required String email,
    required String baseCurrency,
    required String timezone,
    required int firstDayOfMonth,
    String? defaultSpendingAccountId,
    required int lowBalanceThreshold,
  }) = _MeResponse;

  factory MeResponse.fromJson(Map<String, dynamic> json) => _$MeResponseFromJson(json);
}

/// One change in the push request (docs/sync.md).
@freezed
abstract class SyncChangeDto with _$SyncChangeDto {
  const factory SyncChangeDto({
    required String entityType,
    required String id,
    required String operation,
    Map<String, dynamic>? payload,
    required DateTime clientUpdatedAt,
  }) = _SyncChangeDto;

  factory SyncChangeDto.fromJson(Map<String, dynamic> json) => _$SyncChangeDtoFromJson(json);
}

@freezed
abstract class AcceptedChangeDto with _$AcceptedChangeDto {
  const factory AcceptedChangeDto({
    required String entityType,
    required String id,
    required String operation,
    int? version,
    required String status,
  }) = _AcceptedChangeDto;

  factory AcceptedChangeDto.fromJson(Map<String, dynamic> json) => _$AcceptedChangeDtoFromJson(json);
}

@freezed
abstract class RejectedChangeDto with _$RejectedChangeDto {
  const factory RejectedChangeDto({
    String? entityType,
    required String id,
    String? operation,
    required String code,
    required String message,
    Map<String, List<String>>? errors,
  }) = _RejectedChangeDto;

  factory RejectedChangeDto.fromJson(Map<String, dynamic> json) => _$RejectedChangeDtoFromJson(json);
}

@freezed
abstract class PushResponseDto with _$PushResponseDto {
  const factory PushResponseDto({
    @Default([]) List<AcceptedChangeDto> accepted,
    @Default([]) List<RejectedChangeDto> rejected,
  }) = _PushResponseDto;

  factory PushResponseDto.fromJson(Map<String, dynamic> json) => _$PushResponseDtoFromJson(json);
}

@freezed
abstract class PulledChangeDto with _$PulledChangeDto {
  const factory PulledChangeDto({
    required String entityType,
    required String id,
    required int version,
    required bool deleted,
    DateTime? deletedAt,
    required DateTime updatedAt,
    Map<String, dynamic>? data,
  }) = _PulledChangeDto;

  factory PulledChangeDto.fromJson(Map<String, dynamic> json) => _$PulledChangeDtoFromJson(json);
}

@freezed
abstract class PullResponseDto with _$PullResponseDto {
  const factory PullResponseDto({
    @Default([]) List<PulledChangeDto> changes,
    required int nextCursor,
    required bool hasMore,
  }) = _PullResponseDto;

  factory PullResponseDto.fromJson(Map<String, dynamic> json) => _$PullResponseDtoFromJson(json);
}

@freezed
abstract class RateDto with _$RateDto {
  const factory RateDto({required String currency, required num rate, required String date}) = _RateDto;

  factory RateDto.fromJson(Map<String, dynamic> json) => _$RateDtoFromJson(json);
}

@freezed
abstract class RatesResponseDto with _$RatesResponseDto {
  const factory RatesResponseDto({required String baseCurrency, required String date, @Default([]) List<RateDto> rates}) =
      _RatesResponseDto;

  factory RatesResponseDto.fromJson(Map<String, dynamic> json) => _$RatesResponseDtoFromJson(json);
}
