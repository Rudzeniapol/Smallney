// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt'] as String,
      ),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.parse(
        json['refreshTokenExpiresAt'] as String,
      ),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'accessTokenExpiresAt': instance.accessTokenExpiresAt.toIso8601String(),
      'refreshToken': instance.refreshToken,
      'refreshTokenExpiresAt': instance.refreshTokenExpiresAt.toIso8601String(),
      'userId': instance.userId,
    };

_MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => _MeResponse(
  id: json['id'] as String,
  email: json['email'] as String,
  baseCurrency: json['baseCurrency'] as String,
  timezone: json['timezone'] as String,
  firstDayOfMonth: (json['firstDayOfMonth'] as num).toInt(),
  defaultSpendingAccountId: json['defaultSpendingAccountId'] as String?,
  lowBalanceThreshold: (json['lowBalanceThreshold'] as num).toInt(),
);

Map<String, dynamic> _$MeResponseToJson(_MeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'baseCurrency': instance.baseCurrency,
      'timezone': instance.timezone,
      'firstDayOfMonth': instance.firstDayOfMonth,
      'defaultSpendingAccountId': instance.defaultSpendingAccountId,
      'lowBalanceThreshold': instance.lowBalanceThreshold,
    };

_SyncChangeDto _$SyncChangeDtoFromJson(Map<String, dynamic> json) =>
    _SyncChangeDto(
      entityType: json['entityType'] as String,
      id: json['id'] as String,
      operation: json['operation'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      clientUpdatedAt: DateTime.parse(json['clientUpdatedAt'] as String),
    );

Map<String, dynamic> _$SyncChangeDtoToJson(_SyncChangeDto instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'id': instance.id,
      'operation': instance.operation,
      'payload': instance.payload,
      'clientUpdatedAt': instance.clientUpdatedAt.toIso8601String(),
    };

_AcceptedChangeDto _$AcceptedChangeDtoFromJson(Map<String, dynamic> json) =>
    _AcceptedChangeDto(
      entityType: json['entityType'] as String,
      id: json['id'] as String,
      operation: json['operation'] as String,
      version: (json['version'] as num?)?.toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$AcceptedChangeDtoToJson(_AcceptedChangeDto instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'id': instance.id,
      'operation': instance.operation,
      'version': instance.version,
      'status': instance.status,
    };

_RejectedChangeDto _$RejectedChangeDtoFromJson(Map<String, dynamic> json) =>
    _RejectedChangeDto(
      entityType: json['entityType'] as String?,
      id: json['id'] as String,
      operation: json['operation'] as String?,
      code: json['code'] as String,
      message: json['message'] as String,
      errors: (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$RejectedChangeDtoToJson(_RejectedChangeDto instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'id': instance.id,
      'operation': instance.operation,
      'code': instance.code,
      'message': instance.message,
      'errors': instance.errors,
    };

_PushResponseDto _$PushResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PushResponseDto(
  accepted:
      (json['accepted'] as List<dynamic>?)
          ?.map((e) => AcceptedChangeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  rejected:
      (json['rejected'] as List<dynamic>?)
          ?.map((e) => RejectedChangeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PushResponseDtoToJson(_PushResponseDto instance) =>
    <String, dynamic>{
      'accepted': instance.accepted.map((e) => e.toJson()).toList(),
      'rejected': instance.rejected.map((e) => e.toJson()).toList(),
    };

_PulledChangeDto _$PulledChangeDtoFromJson(Map<String, dynamic> json) =>
    _PulledChangeDto(
      entityType: json['entityType'] as String,
      id: json['id'] as String,
      version: (json['version'] as num).toInt(),
      deleted: json['deleted'] as bool,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PulledChangeDtoToJson(_PulledChangeDto instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'id': instance.id,
      'version': instance.version,
      'deleted': instance.deleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'data': instance.data,
    };

_PullResponseDto _$PullResponseDtoFromJson(Map<String, dynamic> json) =>
    _PullResponseDto(
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map((e) => PulledChangeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextCursor: (json['nextCursor'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$PullResponseDtoToJson(_PullResponseDto instance) =>
    <String, dynamic>{
      'changes': instance.changes.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
    };

_RateDto _$RateDtoFromJson(Map<String, dynamic> json) => _RateDto(
  currency: json['currency'] as String,
  rate: json['rate'] as num,
  date: json['date'] as String,
);

Map<String, dynamic> _$RateDtoToJson(_RateDto instance) => <String, dynamic>{
  'currency': instance.currency,
  'rate': instance.rate,
  'date': instance.date,
};

_RatesResponseDto _$RatesResponseDtoFromJson(Map<String, dynamic> json) =>
    _RatesResponseDto(
      baseCurrency: json['baseCurrency'] as String,
      date: json['date'] as String,
      rates:
          (json['rates'] as List<dynamic>?)
              ?.map((e) => RateDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RatesResponseDtoToJson(_RatesResponseDto instance) =>
    <String, dynamic>{
      'baseCurrency': instance.baseCurrency,
      'date': instance.date,
      'rates': instance.rates.map((e) => e.toJson()).toList(),
    };
