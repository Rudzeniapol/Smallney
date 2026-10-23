// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthResponse {

 String get accessToken; DateTime get accessTokenExpiresAt; String get refreshToken; DateTime get refreshTokenExpiresAt; String get userId;
/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseCopyWith<AuthResponse> get copyWith => _$AuthResponseCopyWithImpl<AuthResponse>(this as AuthResponse, _$identity);

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuthResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponse&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.accessTokenExpiresAt, _this.accessTokenExpiresAt) || other.accessTokenExpiresAt == _this.accessTokenExpiresAt)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.refreshTokenExpiresAt, _this.refreshTokenExpiresAt) || other.refreshTokenExpiresAt == _this.refreshTokenExpiresAt)&&(identical(other.userId, _this.userId) || other.userId == _this.userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuthResponse;
  return Object.hash(runtimeType,_this.accessToken,_this.accessTokenExpiresAt,_this.refreshToken,_this.refreshTokenExpiresAt,_this.userId);
}

@override
String toString() {
  final _this = this as AuthResponse;
  return 'AuthResponse(accessToken: ${_this.accessToken}, accessTokenExpiresAt: ${_this.accessTokenExpiresAt}, refreshToken: ${_this.refreshToken}, refreshTokenExpiresAt: ${_this.refreshTokenExpiresAt}, userId: ${_this.userId})';
}


}

/// @nodoc
abstract mixin class $AuthResponseCopyWith<$Res>  {
  factory $AuthResponseCopyWith(AuthResponse value, $Res Function(AuthResponse) _then) = _$AuthResponseCopyWithImpl;
@useResult
$Res call({
 String accessToken, DateTime accessTokenExpiresAt, String refreshToken, DateTime refreshTokenExpiresAt, String userId
});




}
/// @nodoc
class _$AuthResponseCopyWithImpl<$Res>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._self, this._then);

  final AuthResponse _self;
  final $Res Function(AuthResponse) _then;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? accessTokenExpiresAt = null,Object? refreshToken = null,Object? refreshTokenExpiresAt = null,Object? userId = null,}) {
  return _then(AuthResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenExpiresAt: null == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,refreshTokenExpiresAt: null == refreshTokenExpiresAt ? _self.refreshTokenExpiresAt : refreshTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthResponse].
extension AuthResponsePatterns on AuthResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponse value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  DateTime accessTokenExpiresAt,  String refreshToken,  DateTime refreshTokenExpiresAt,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that.accessToken,_that.accessTokenExpiresAt,_that.refreshToken,_that.refreshTokenExpiresAt,_that.userId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  DateTime accessTokenExpiresAt,  String refreshToken,  DateTime refreshTokenExpiresAt,  String userId)  $default,) {final _that = this;
switch (_that) {
case _AuthResponse():
return $default(_that.accessToken,_that.accessTokenExpiresAt,_that.refreshToken,_that.refreshTokenExpiresAt,_that.userId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  DateTime accessTokenExpiresAt,  String refreshToken,  DateTime refreshTokenExpiresAt,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that.accessToken,_that.accessTokenExpiresAt,_that.refreshToken,_that.refreshTokenExpiresAt,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResponse implements AuthResponse {
  const _AuthResponse({required this.accessToken, required this.accessTokenExpiresAt, required this.refreshToken, required this.refreshTokenExpiresAt, required this.userId});
  factory _AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

@override final  String accessToken;
@override final  DateTime accessTokenExpiresAt;
@override final  String refreshToken;
@override final  DateTime refreshTokenExpiresAt;
@override final  String userId;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseCopyWith<_AuthResponse> get copyWith => __$AuthResponseCopyWithImpl<_AuthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponse&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.accessTokenExpiresAt, accessTokenExpiresAt) || other.accessTokenExpiresAt == accessTokenExpiresAt)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.refreshTokenExpiresAt, refreshTokenExpiresAt) || other.refreshTokenExpiresAt == refreshTokenExpiresAt)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accessToken,accessTokenExpiresAt,refreshToken,refreshTokenExpiresAt,userId);
}

@override
String toString() {
    return 'AuthResponse(accessToken: $accessToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshToken: $refreshToken, refreshTokenExpiresAt: $refreshTokenExpiresAt, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$AuthResponseCopyWith<$Res> implements $AuthResponseCopyWith<$Res> {
  factory _$AuthResponseCopyWith(_AuthResponse value, $Res Function(_AuthResponse) _then) = __$AuthResponseCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, DateTime accessTokenExpiresAt, String refreshToken, DateTime refreshTokenExpiresAt, String userId
});




}
/// @nodoc
class __$AuthResponseCopyWithImpl<$Res>
    implements _$AuthResponseCopyWith<$Res> {
  __$AuthResponseCopyWithImpl(this._self, this._then);

  final _AuthResponse _self;
  final $Res Function(_AuthResponse) _then;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? accessTokenExpiresAt = null,Object? refreshToken = null,Object? refreshTokenExpiresAt = null,Object? userId = null,}) {
  return _then(_AuthResponse(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenExpiresAt: null == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,refreshTokenExpiresAt: null == refreshTokenExpiresAt ? _self.refreshTokenExpiresAt : refreshTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MeResponse {

 String get id; String get email; String get baseCurrency; String get timezone; int get firstDayOfMonth; String? get defaultSpendingAccountId; int get lowBalanceThreshold;
/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeResponseCopyWith<MeResponse> get copyWith => _$MeResponseCopyWithImpl<MeResponse>(this as MeResponse, _$identity);

  /// Serializes this MeResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MeResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeResponse&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.baseCurrency, _this.baseCurrency) || other.baseCurrency == _this.baseCurrency)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.firstDayOfMonth, _this.firstDayOfMonth) || other.firstDayOfMonth == _this.firstDayOfMonth)&&(identical(other.defaultSpendingAccountId, _this.defaultSpendingAccountId) || other.defaultSpendingAccountId == _this.defaultSpendingAccountId)&&(identical(other.lowBalanceThreshold, _this.lowBalanceThreshold) || other.lowBalanceThreshold == _this.lowBalanceThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MeResponse;
  return Object.hash(runtimeType,_this.id,_this.email,_this.baseCurrency,_this.timezone,_this.firstDayOfMonth,_this.defaultSpendingAccountId,_this.lowBalanceThreshold);
}

@override
String toString() {
  final _this = this as MeResponse;
  return 'MeResponse(id: ${_this.id}, email: ${_this.email}, baseCurrency: ${_this.baseCurrency}, timezone: ${_this.timezone}, firstDayOfMonth: ${_this.firstDayOfMonth}, defaultSpendingAccountId: ${_this.defaultSpendingAccountId}, lowBalanceThreshold: ${_this.lowBalanceThreshold})';
}


}

/// @nodoc
abstract mixin class $MeResponseCopyWith<$Res>  {
  factory $MeResponseCopyWith(MeResponse value, $Res Function(MeResponse) _then) = _$MeResponseCopyWithImpl;
@useResult
$Res call({
 String id, String email, String baseCurrency, String timezone, int firstDayOfMonth, String? defaultSpendingAccountId, int lowBalanceThreshold
});




}
/// @nodoc
class _$MeResponseCopyWithImpl<$Res>
    implements $MeResponseCopyWith<$Res> {
  _$MeResponseCopyWithImpl(this._self, this._then);

  final MeResponse _self;
  final $Res Function(MeResponse) _then;

/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? baseCurrency = null,Object? timezone = null,Object? firstDayOfMonth = null,Object? defaultSpendingAccountId = freezed,Object? lowBalanceThreshold = null,}) {
  return _then(MeResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,firstDayOfMonth: null == firstDayOfMonth ? _self.firstDayOfMonth : firstDayOfMonth // ignore: cast_nullable_to_non_nullable
as int,defaultSpendingAccountId: freezed == defaultSpendingAccountId ? _self.defaultSpendingAccountId : defaultSpendingAccountId // ignore: cast_nullable_to_non_nullable
as String?,lowBalanceThreshold: null == lowBalanceThreshold ? _self.lowBalanceThreshold : lowBalanceThreshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MeResponse].
extension MeResponsePatterns on MeResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeResponse value)  $default,){
final _that = this;
switch (_that) {
case _MeResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String baseCurrency,  String timezone,  int firstDayOfMonth,  String? defaultSpendingAccountId,  int lowBalanceThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
return $default(_that.id,_that.email,_that.baseCurrency,_that.timezone,_that.firstDayOfMonth,_that.defaultSpendingAccountId,_that.lowBalanceThreshold);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String baseCurrency,  String timezone,  int firstDayOfMonth,  String? defaultSpendingAccountId,  int lowBalanceThreshold)  $default,) {final _that = this;
switch (_that) {
case _MeResponse():
return $default(_that.id,_that.email,_that.baseCurrency,_that.timezone,_that.firstDayOfMonth,_that.defaultSpendingAccountId,_that.lowBalanceThreshold);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String baseCurrency,  String timezone,  int firstDayOfMonth,  String? defaultSpendingAccountId,  int lowBalanceThreshold)?  $default,) {final _that = this;
switch (_that) {
case _MeResponse() when $default != null:
return $default(_that.id,_that.email,_that.baseCurrency,_that.timezone,_that.firstDayOfMonth,_that.defaultSpendingAccountId,_that.lowBalanceThreshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeResponse implements MeResponse {
  const _MeResponse({required this.id, required this.email, required this.baseCurrency, required this.timezone, required this.firstDayOfMonth, this.defaultSpendingAccountId, required this.lowBalanceThreshold});
  factory _MeResponse.fromJson(Map<String, dynamic> json) => _$MeResponseFromJson(json);

@override final  String id;
@override final  String email;
@override final  String baseCurrency;
@override final  String timezone;
@override final  int firstDayOfMonth;
@override final  String? defaultSpendingAccountId;
@override final  int lowBalanceThreshold;

/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeResponseCopyWith<_MeResponse> get copyWith => __$MeResponseCopyWithImpl<_MeResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.firstDayOfMonth, firstDayOfMonth) || other.firstDayOfMonth == firstDayOfMonth)&&(identical(other.defaultSpendingAccountId, defaultSpendingAccountId) || other.defaultSpendingAccountId == defaultSpendingAccountId)&&(identical(other.lowBalanceThreshold, lowBalanceThreshold) || other.lowBalanceThreshold == lowBalanceThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,email,baseCurrency,timezone,firstDayOfMonth,defaultSpendingAccountId,lowBalanceThreshold);
}

@override
String toString() {
    return 'MeResponse(id: $id, email: $email, baseCurrency: $baseCurrency, timezone: $timezone, firstDayOfMonth: $firstDayOfMonth, defaultSpendingAccountId: $defaultSpendingAccountId, lowBalanceThreshold: $lowBalanceThreshold)';
}


}

/// @nodoc
abstract mixin class _$MeResponseCopyWith<$Res> implements $MeResponseCopyWith<$Res> {
  factory _$MeResponseCopyWith(_MeResponse value, $Res Function(_MeResponse) _then) = __$MeResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String baseCurrency, String timezone, int firstDayOfMonth, String? defaultSpendingAccountId, int lowBalanceThreshold
});




}
/// @nodoc
class __$MeResponseCopyWithImpl<$Res>
    implements _$MeResponseCopyWith<$Res> {
  __$MeResponseCopyWithImpl(this._self, this._then);

  final _MeResponse _self;
  final $Res Function(_MeResponse) _then;

/// Create a copy of MeResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? baseCurrency = null,Object? timezone = null,Object? firstDayOfMonth = null,Object? defaultSpendingAccountId = freezed,Object? lowBalanceThreshold = null,}) {
  return _then(_MeResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,firstDayOfMonth: null == firstDayOfMonth ? _self.firstDayOfMonth : firstDayOfMonth // ignore: cast_nullable_to_non_nullable
as int,defaultSpendingAccountId: freezed == defaultSpendingAccountId ? _self.defaultSpendingAccountId : defaultSpendingAccountId // ignore: cast_nullable_to_non_nullable
as String?,lowBalanceThreshold: null == lowBalanceThreshold ? _self.lowBalanceThreshold : lowBalanceThreshold // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SyncChangeDto {

 String get entityType; String get id; String get operation; Map<String, dynamic>? get payload; DateTime get clientUpdatedAt;
/// Create a copy of SyncChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncChangeDtoCopyWith<SyncChangeDto> get copyWith => _$SyncChangeDtoCopyWithImpl<SyncChangeDto>(this as SyncChangeDto, _$identity);

  /// Serializes this SyncChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SyncChangeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncChangeDto&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.operation, _this.operation) || other.operation == _this.operation)&&const DeepCollectionEquality().equals(other.payload, _this.payload)&&(identical(other.clientUpdatedAt, _this.clientUpdatedAt) || other.clientUpdatedAt == _this.clientUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SyncChangeDto;
  return Object.hash(runtimeType,_this.entityType,_this.id,_this.operation,const DeepCollectionEquality().hash(_this.payload),_this.clientUpdatedAt);
}

@override
String toString() {
  final _this = this as SyncChangeDto;
  return 'SyncChangeDto(entityType: ${_this.entityType}, id: ${_this.id}, operation: ${_this.operation}, payload: ${_this.payload}, clientUpdatedAt: ${_this.clientUpdatedAt})';
}


}

/// @nodoc
abstract mixin class $SyncChangeDtoCopyWith<$Res>  {
  factory $SyncChangeDtoCopyWith(SyncChangeDto value, $Res Function(SyncChangeDto) _then) = _$SyncChangeDtoCopyWithImpl;
@useResult
$Res call({
 String entityType, String id, String operation, Map<String, dynamic>? payload, DateTime clientUpdatedAt
});




}
/// @nodoc
class _$SyncChangeDtoCopyWithImpl<$Res>
    implements $SyncChangeDtoCopyWith<$Res> {
  _$SyncChangeDtoCopyWithImpl(this._self, this._then);

  final SyncChangeDto _self;
  final $Res Function(SyncChangeDto) _then;

/// Create a copy of SyncChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = null,Object? id = null,Object? operation = null,Object? payload = freezed,Object? clientUpdatedAt = null,}) {
  return _then(SyncChangeDto(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clientUpdatedAt: null == clientUpdatedAt ? _self.clientUpdatedAt : clientUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncChangeDto].
extension SyncChangeDtoPatterns on SyncChangeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncChangeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _SyncChangeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _SyncChangeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityType,  String id,  String operation,  Map<String, dynamic>? payload,  DateTime clientUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.operation,_that.payload,_that.clientUpdatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityType,  String id,  String operation,  Map<String, dynamic>? payload,  DateTime clientUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _SyncChangeDto():
return $default(_that.entityType,_that.id,_that.operation,_that.payload,_that.clientUpdatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityType,  String id,  String operation,  Map<String, dynamic>? payload,  DateTime clientUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SyncChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.operation,_that.payload,_that.clientUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncChangeDto implements SyncChangeDto {
  const _SyncChangeDto({required this.entityType, required this.id, required this.operation,  Map<String, dynamic>? payload, required this.clientUpdatedAt}): _payload = payload;
  factory _SyncChangeDto.fromJson(Map<String, dynamic> json) => _$SyncChangeDtoFromJson(json);

@override final  String entityType;
@override final  String id;
@override final  String operation;
 final  Map<String, dynamic>? _payload;
@override Map<String, dynamic>? get payload {
  final value = _payload;
  if (value == null) return null;
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime clientUpdatedAt;

/// Create a copy of SyncChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncChangeDtoCopyWith<_SyncChangeDto> get copyWith => __$SyncChangeDtoCopyWithImpl<_SyncChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncChangeDto&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.id, id) || other.id == id)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other.payload, _payload)&&(identical(other.clientUpdatedAt, clientUpdatedAt) || other.clientUpdatedAt == clientUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityType,id,operation,const DeepCollectionEquality().hash(_payload),clientUpdatedAt);
}

@override
String toString() {
    return 'SyncChangeDto(entityType: $entityType, id: $id, operation: $operation, payload: $payload, clientUpdatedAt: $clientUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$SyncChangeDtoCopyWith<$Res> implements $SyncChangeDtoCopyWith<$Res> {
  factory _$SyncChangeDtoCopyWith(_SyncChangeDto value, $Res Function(_SyncChangeDto) _then) = __$SyncChangeDtoCopyWithImpl;
@override @useResult
$Res call({
 String entityType, String id, String operation, Map<String, dynamic>? payload, DateTime clientUpdatedAt
});




}
/// @nodoc
class __$SyncChangeDtoCopyWithImpl<$Res>
    implements _$SyncChangeDtoCopyWith<$Res> {
  __$SyncChangeDtoCopyWithImpl(this._self, this._then);

  final _SyncChangeDto _self;
  final $Res Function(_SyncChangeDto) _then;

/// Create a copy of SyncChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = null,Object? id = null,Object? operation = null,Object? payload = freezed,Object? clientUpdatedAt = null,}) {
  return _then(_SyncChangeDto(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,payload: freezed == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clientUpdatedAt: null == clientUpdatedAt ? _self.clientUpdatedAt : clientUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AcceptedChangeDto {

 String get entityType; String get id; String get operation; int? get version; String get status;
/// Create a copy of AcceptedChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptedChangeDtoCopyWith<AcceptedChangeDto> get copyWith => _$AcceptedChangeDtoCopyWithImpl<AcceptedChangeDto>(this as AcceptedChangeDto, _$identity);

  /// Serializes this AcceptedChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AcceptedChangeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptedChangeDto&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.operation, _this.operation) || other.operation == _this.operation)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AcceptedChangeDto;
  return Object.hash(runtimeType,_this.entityType,_this.id,_this.operation,_this.version,_this.status);
}

@override
String toString() {
  final _this = this as AcceptedChangeDto;
  return 'AcceptedChangeDto(entityType: ${_this.entityType}, id: ${_this.id}, operation: ${_this.operation}, version: ${_this.version}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $AcceptedChangeDtoCopyWith<$Res>  {
  factory $AcceptedChangeDtoCopyWith(AcceptedChangeDto value, $Res Function(AcceptedChangeDto) _then) = _$AcceptedChangeDtoCopyWithImpl;
@useResult
$Res call({
 String entityType, String id, String operation, int? version, String status
});




}
/// @nodoc
class _$AcceptedChangeDtoCopyWithImpl<$Res>
    implements $AcceptedChangeDtoCopyWith<$Res> {
  _$AcceptedChangeDtoCopyWithImpl(this._self, this._then);

  final AcceptedChangeDto _self;
  final $Res Function(AcceptedChangeDto) _then;

/// Create a copy of AcceptedChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = null,Object? id = null,Object? operation = null,Object? version = freezed,Object? status = null,}) {
  return _then(AcceptedChangeDto(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AcceptedChangeDto].
extension AcceptedChangeDtoPatterns on AcceptedChangeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptedChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptedChangeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptedChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _AcceptedChangeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptedChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptedChangeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityType,  String id,  String operation,  int? version,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptedChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.operation,_that.version,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityType,  String id,  String operation,  int? version,  String status)  $default,) {final _that = this;
switch (_that) {
case _AcceptedChangeDto():
return $default(_that.entityType,_that.id,_that.operation,_that.version,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityType,  String id,  String operation,  int? version,  String status)?  $default,) {final _that = this;
switch (_that) {
case _AcceptedChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.operation,_that.version,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AcceptedChangeDto implements AcceptedChangeDto {
  const _AcceptedChangeDto({required this.entityType, required this.id, required this.operation, this.version, required this.status});
  factory _AcceptedChangeDto.fromJson(Map<String, dynamic> json) => _$AcceptedChangeDtoFromJson(json);

@override final  String entityType;
@override final  String id;
@override final  String operation;
@override final  int? version;
@override final  String status;

/// Create a copy of AcceptedChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptedChangeDtoCopyWith<_AcceptedChangeDto> get copyWith => __$AcceptedChangeDtoCopyWithImpl<_AcceptedChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AcceptedChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptedChangeDto&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.id, id) || other.id == id)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityType,id,operation,version,status);
}

@override
String toString() {
    return 'AcceptedChangeDto(entityType: $entityType, id: $id, operation: $operation, version: $version, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AcceptedChangeDtoCopyWith<$Res> implements $AcceptedChangeDtoCopyWith<$Res> {
  factory _$AcceptedChangeDtoCopyWith(_AcceptedChangeDto value, $Res Function(_AcceptedChangeDto) _then) = __$AcceptedChangeDtoCopyWithImpl;
@override @useResult
$Res call({
 String entityType, String id, String operation, int? version, String status
});




}
/// @nodoc
class __$AcceptedChangeDtoCopyWithImpl<$Res>
    implements _$AcceptedChangeDtoCopyWith<$Res> {
  __$AcceptedChangeDtoCopyWithImpl(this._self, this._then);

  final _AcceptedChangeDto _self;
  final $Res Function(_AcceptedChangeDto) _then;

/// Create a copy of AcceptedChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = null,Object? id = null,Object? operation = null,Object? version = freezed,Object? status = null,}) {
  return _then(_AcceptedChangeDto(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RejectedChangeDto {

 String? get entityType; String get id; String? get operation; String get code; String get message; Map<String, List<String>>? get errors;
/// Create a copy of RejectedChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RejectedChangeDtoCopyWith<RejectedChangeDto> get copyWith => _$RejectedChangeDtoCopyWithImpl<RejectedChangeDto>(this as RejectedChangeDto, _$identity);

  /// Serializes this RejectedChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RejectedChangeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RejectedChangeDto&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.operation, _this.operation) || other.operation == _this.operation)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RejectedChangeDto;
  return Object.hash(runtimeType,_this.entityType,_this.id,_this.operation,_this.code,_this.message,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as RejectedChangeDto;
  return 'RejectedChangeDto(entityType: ${_this.entityType}, id: ${_this.id}, operation: ${_this.operation}, code: ${_this.code}, message: ${_this.message}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $RejectedChangeDtoCopyWith<$Res>  {
  factory $RejectedChangeDtoCopyWith(RejectedChangeDto value, $Res Function(RejectedChangeDto) _then) = _$RejectedChangeDtoCopyWithImpl;
@useResult
$Res call({
 String? entityType, String id, String? operation, String code, String message, Map<String, List<String>>? errors
});




}
/// @nodoc
class _$RejectedChangeDtoCopyWithImpl<$Res>
    implements $RejectedChangeDtoCopyWith<$Res> {
  _$RejectedChangeDtoCopyWithImpl(this._self, this._then);

  final RejectedChangeDto _self;
  final $Res Function(RejectedChangeDto) _then;

/// Create a copy of RejectedChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = freezed,Object? id = null,Object? operation = freezed,Object? code = null,Object? message = null,Object? errors = freezed,}) {
  return _then(RejectedChangeDto(
entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,errors: freezed == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RejectedChangeDto].
extension RejectedChangeDtoPatterns on RejectedChangeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RejectedChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RejectedChangeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RejectedChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _RejectedChangeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RejectedChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _RejectedChangeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? entityType,  String id,  String? operation,  String code,  String message,  Map<String, List<String>>? errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RejectedChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.operation,_that.code,_that.message,_that.errors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? entityType,  String id,  String? operation,  String code,  String message,  Map<String, List<String>>? errors)  $default,) {final _that = this;
switch (_that) {
case _RejectedChangeDto():
return $default(_that.entityType,_that.id,_that.operation,_that.code,_that.message,_that.errors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? entityType,  String id,  String? operation,  String code,  String message,  Map<String, List<String>>? errors)?  $default,) {final _that = this;
switch (_that) {
case _RejectedChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.operation,_that.code,_that.message,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RejectedChangeDto implements RejectedChangeDto {
  const _RejectedChangeDto({this.entityType, required this.id, this.operation, required this.code, required this.message,  Map<String, List<String>>? errors}): _errors = errors;
  factory _RejectedChangeDto.fromJson(Map<String, dynamic> json) => _$RejectedChangeDtoFromJson(json);

@override final  String? entityType;
@override final  String id;
@override final  String? operation;
@override final  String code;
@override final  String message;
 final  Map<String, List<String>>? _errors;
@override Map<String, List<String>>? get errors {
  final value = _errors;
  if (value == null) return null;
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RejectedChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RejectedChangeDtoCopyWith<_RejectedChangeDto> get copyWith => __$RejectedChangeDtoCopyWithImpl<_RejectedChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RejectedChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RejectedChangeDto&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.id, id) || other.id == id)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityType,id,operation,code,message,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'RejectedChangeDto(entityType: $entityType, id: $id, operation: $operation, code: $code, message: $message, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$RejectedChangeDtoCopyWith<$Res> implements $RejectedChangeDtoCopyWith<$Res> {
  factory _$RejectedChangeDtoCopyWith(_RejectedChangeDto value, $Res Function(_RejectedChangeDto) _then) = __$RejectedChangeDtoCopyWithImpl;
@override @useResult
$Res call({
 String? entityType, String id, String? operation, String code, String message, Map<String, List<String>>? errors
});




}
/// @nodoc
class __$RejectedChangeDtoCopyWithImpl<$Res>
    implements _$RejectedChangeDtoCopyWith<$Res> {
  __$RejectedChangeDtoCopyWithImpl(this._self, this._then);

  final _RejectedChangeDto _self;
  final $Res Function(_RejectedChangeDto) _then;

/// Create a copy of RejectedChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = freezed,Object? id = null,Object? operation = freezed,Object? code = null,Object? message = null,Object? errors = freezed,}) {
  return _then(_RejectedChangeDto(
entityType: freezed == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,operation: freezed == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,errors: freezed == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>?,
  ));
}


}


/// @nodoc
mixin _$PushResponseDto {

 List<AcceptedChangeDto> get accepted; List<RejectedChangeDto> get rejected;
/// Create a copy of PushResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushResponseDtoCopyWith<PushResponseDto> get copyWith => _$PushResponseDtoCopyWithImpl<PushResponseDto>(this as PushResponseDto, _$identity);

  /// Serializes this PushResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PushResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushResponseDto&&const DeepCollectionEquality().equals(other.accepted, _this.accepted)&&const DeepCollectionEquality().equals(other.rejected, _this.rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PushResponseDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.accepted),const DeepCollectionEquality().hash(_this.rejected));
}

@override
String toString() {
  final _this = this as PushResponseDto;
  return 'PushResponseDto(accepted: ${_this.accepted}, rejected: ${_this.rejected})';
}


}

/// @nodoc
abstract mixin class $PushResponseDtoCopyWith<$Res>  {
  factory $PushResponseDtoCopyWith(PushResponseDto value, $Res Function(PushResponseDto) _then) = _$PushResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<AcceptedChangeDto> accepted, List<RejectedChangeDto> rejected
});




}
/// @nodoc
class _$PushResponseDtoCopyWithImpl<$Res>
    implements $PushResponseDtoCopyWith<$Res> {
  _$PushResponseDtoCopyWithImpl(this._self, this._then);

  final PushResponseDto _self;
  final $Res Function(PushResponseDto) _then;

/// Create a copy of PushResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accepted = null,Object? rejected = null,}) {
  return _then(PushResponseDto(
accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as List<AcceptedChangeDto>,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<RejectedChangeDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [PushResponseDto].
extension PushResponseDtoPatterns on PushResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PushResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PushResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AcceptedChangeDto> accepted,  List<RejectedChangeDto> rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushResponseDto() when $default != null:
return $default(_that.accepted,_that.rejected);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AcceptedChangeDto> accepted,  List<RejectedChangeDto> rejected)  $default,) {final _that = this;
switch (_that) {
case _PushResponseDto():
return $default(_that.accepted,_that.rejected);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AcceptedChangeDto> accepted,  List<RejectedChangeDto> rejected)?  $default,) {final _that = this;
switch (_that) {
case _PushResponseDto() when $default != null:
return $default(_that.accepted,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PushResponseDto implements PushResponseDto {
  const _PushResponseDto({ List<AcceptedChangeDto> accepted = const [],  List<RejectedChangeDto> rejected = const []}): _accepted = accepted,_rejected = rejected;
  factory _PushResponseDto.fromJson(Map<String, dynamic> json) => _$PushResponseDtoFromJson(json);

 final  List<AcceptedChangeDto> _accepted;
@override@JsonKey() List<AcceptedChangeDto> get accepted {
  if (_accepted is EqualUnmodifiableListView) return _accepted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accepted);
}

 final  List<RejectedChangeDto> _rejected;
@override@JsonKey() List<RejectedChangeDto> get rejected {
  if (_rejected is EqualUnmodifiableListView) return _rejected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejected);
}


/// Create a copy of PushResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushResponseDtoCopyWith<_PushResponseDto> get copyWith => __$PushResponseDtoCopyWithImpl<_PushResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PushResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushResponseDto&&const DeepCollectionEquality().equals(other.accepted, _accepted)&&const DeepCollectionEquality().equals(other.rejected, _rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_accepted),const DeepCollectionEquality().hash(_rejected));
}

@override
String toString() {
    return 'PushResponseDto(accepted: $accepted, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$PushResponseDtoCopyWith<$Res> implements $PushResponseDtoCopyWith<$Res> {
  factory _$PushResponseDtoCopyWith(_PushResponseDto value, $Res Function(_PushResponseDto) _then) = __$PushResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<AcceptedChangeDto> accepted, List<RejectedChangeDto> rejected
});




}
/// @nodoc
class __$PushResponseDtoCopyWithImpl<$Res>
    implements _$PushResponseDtoCopyWith<$Res> {
  __$PushResponseDtoCopyWithImpl(this._self, this._then);

  final _PushResponseDto _self;
  final $Res Function(_PushResponseDto) _then;

/// Create a copy of PushResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accepted = null,Object? rejected = null,}) {
  return _then(_PushResponseDto(
accepted: null == accepted ? _self._accepted : accepted // ignore: cast_nullable_to_non_nullable
as List<AcceptedChangeDto>,rejected: null == rejected ? _self._rejected : rejected // ignore: cast_nullable_to_non_nullable
as List<RejectedChangeDto>,
  ));
}


}


/// @nodoc
mixin _$PulledChangeDto {

 String get entityType; String get id; int get version; bool get deleted; DateTime? get deletedAt; DateTime get updatedAt; Map<String, dynamic>? get data;
/// Create a copy of PulledChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PulledChangeDtoCopyWith<PulledChangeDto> get copyWith => _$PulledChangeDtoCopyWithImpl<PulledChangeDto>(this as PulledChangeDto, _$identity);

  /// Serializes this PulledChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PulledChangeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PulledChangeDto&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PulledChangeDto;
  return Object.hash(runtimeType,_this.entityType,_this.id,_this.version,_this.deleted,_this.deletedAt,_this.updatedAt,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as PulledChangeDto;
  return 'PulledChangeDto(entityType: ${_this.entityType}, id: ${_this.id}, version: ${_this.version}, deleted: ${_this.deleted}, deletedAt: ${_this.deletedAt}, updatedAt: ${_this.updatedAt}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $PulledChangeDtoCopyWith<$Res>  {
  factory $PulledChangeDtoCopyWith(PulledChangeDto value, $Res Function(PulledChangeDto) _then) = _$PulledChangeDtoCopyWithImpl;
@useResult
$Res call({
 String entityType, String id, int version, bool deleted, DateTime? deletedAt, DateTime updatedAt, Map<String, dynamic>? data
});




}
/// @nodoc
class _$PulledChangeDtoCopyWithImpl<$Res>
    implements $PulledChangeDtoCopyWith<$Res> {
  _$PulledChangeDtoCopyWithImpl(this._self, this._then);

  final PulledChangeDto _self;
  final $Res Function(PulledChangeDto) _then;

/// Create a copy of PulledChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entityType = null,Object? id = null,Object? version = null,Object? deleted = null,Object? deletedAt = freezed,Object? updatedAt = null,Object? data = freezed,}) {
  return _then(PulledChangeDto(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PulledChangeDto].
extension PulledChangeDtoPatterns on PulledChangeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PulledChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PulledChangeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PulledChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _PulledChangeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PulledChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PulledChangeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String entityType,  String id,  int version,  bool deleted,  DateTime? deletedAt,  DateTime updatedAt,  Map<String, dynamic>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PulledChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.version,_that.deleted,_that.deletedAt,_that.updatedAt,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String entityType,  String id,  int version,  bool deleted,  DateTime? deletedAt,  DateTime updatedAt,  Map<String, dynamic>? data)  $default,) {final _that = this;
switch (_that) {
case _PulledChangeDto():
return $default(_that.entityType,_that.id,_that.version,_that.deleted,_that.deletedAt,_that.updatedAt,_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String entityType,  String id,  int version,  bool deleted,  DateTime? deletedAt,  DateTime updatedAt,  Map<String, dynamic>? data)?  $default,) {final _that = this;
switch (_that) {
case _PulledChangeDto() when $default != null:
return $default(_that.entityType,_that.id,_that.version,_that.deleted,_that.deletedAt,_that.updatedAt,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PulledChangeDto implements PulledChangeDto {
  const _PulledChangeDto({required this.entityType, required this.id, required this.version, required this.deleted, this.deletedAt, required this.updatedAt,  Map<String, dynamic>? data}): _data = data;
  factory _PulledChangeDto.fromJson(Map<String, dynamic> json) => _$PulledChangeDtoFromJson(json);

@override final  String entityType;
@override final  String id;
@override final  int version;
@override final  bool deleted;
@override final  DateTime? deletedAt;
@override final  DateTime updatedAt;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PulledChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PulledChangeDtoCopyWith<_PulledChangeDto> get copyWith => __$PulledChangeDtoCopyWithImpl<_PulledChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PulledChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PulledChangeDto&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,entityType,id,version,deleted,deletedAt,updatedAt,const DeepCollectionEquality().hash(_data));
}

@override
String toString() {
    return 'PulledChangeDto(entityType: $entityType, id: $id, version: $version, deleted: $deleted, deletedAt: $deletedAt, updatedAt: $updatedAt, data: $data)';
}


}

/// @nodoc
abstract mixin class _$PulledChangeDtoCopyWith<$Res> implements $PulledChangeDtoCopyWith<$Res> {
  factory _$PulledChangeDtoCopyWith(_PulledChangeDto value, $Res Function(_PulledChangeDto) _then) = __$PulledChangeDtoCopyWithImpl;
@override @useResult
$Res call({
 String entityType, String id, int version, bool deleted, DateTime? deletedAt, DateTime updatedAt, Map<String, dynamic>? data
});




}
/// @nodoc
class __$PulledChangeDtoCopyWithImpl<$Res>
    implements _$PulledChangeDtoCopyWith<$Res> {
  __$PulledChangeDtoCopyWithImpl(this._self, this._then);

  final _PulledChangeDto _self;
  final $Res Function(_PulledChangeDto) _then;

/// Create a copy of PulledChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entityType = null,Object? id = null,Object? version = null,Object? deleted = null,Object? deletedAt = freezed,Object? updatedAt = null,Object? data = freezed,}) {
  return _then(_PulledChangeDto(
entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$PullResponseDto {

 List<PulledChangeDto> get changes; int get nextCursor; bool get hasMore;
/// Create a copy of PullResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullResponseDtoCopyWith<PullResponseDto> get copyWith => _$PullResponseDtoCopyWithImpl<PullResponseDto>(this as PullResponseDto, _$identity);

  /// Serializes this PullResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PullResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullResponseDto&&const DeepCollectionEquality().equals(other.changes, _this.changes)&&(identical(other.nextCursor, _this.nextCursor) || other.nextCursor == _this.nextCursor)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PullResponseDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.changes),_this.nextCursor,_this.hasMore);
}

@override
String toString() {
  final _this = this as PullResponseDto;
  return 'PullResponseDto(changes: ${_this.changes}, nextCursor: ${_this.nextCursor}, hasMore: ${_this.hasMore})';
}


}

/// @nodoc
abstract mixin class $PullResponseDtoCopyWith<$Res>  {
  factory $PullResponseDtoCopyWith(PullResponseDto value, $Res Function(PullResponseDto) _then) = _$PullResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<PulledChangeDto> changes, int nextCursor, bool hasMore
});




}
/// @nodoc
class _$PullResponseDtoCopyWithImpl<$Res>
    implements $PullResponseDtoCopyWith<$Res> {
  _$PullResponseDtoCopyWithImpl(this._self, this._then);

  final PullResponseDto _self;
  final $Res Function(PullResponseDto) _then;

/// Create a copy of PullResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? changes = null,Object? nextCursor = null,Object? hasMore = null,}) {
  return _then(PullResponseDto(
changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<PulledChangeDto>,nextCursor: null == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PullResponseDto].
extension PullResponseDtoPatterns on PullResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PullResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PullResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PullResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PullResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PullResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PullResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PulledChangeDto> changes,  int nextCursor,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PullResponseDto() when $default != null:
return $default(_that.changes,_that.nextCursor,_that.hasMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PulledChangeDto> changes,  int nextCursor,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _PullResponseDto():
return $default(_that.changes,_that.nextCursor,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PulledChangeDto> changes,  int nextCursor,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _PullResponseDto() when $default != null:
return $default(_that.changes,_that.nextCursor,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PullResponseDto implements PullResponseDto {
  const _PullResponseDto({ List<PulledChangeDto> changes = const [], required this.nextCursor, required this.hasMore}): _changes = changes;
  factory _PullResponseDto.fromJson(Map<String, dynamic> json) => _$PullResponseDtoFromJson(json);

 final  List<PulledChangeDto> _changes;
@override@JsonKey() List<PulledChangeDto> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}

@override final  int nextCursor;
@override final  bool hasMore;

/// Create a copy of PullResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PullResponseDtoCopyWith<_PullResponseDto> get copyWith => __$PullResponseDtoCopyWithImpl<_PullResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PullResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PullResponseDto&&const DeepCollectionEquality().equals(other.changes, _changes)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_changes),nextCursor,hasMore);
}

@override
String toString() {
    return 'PullResponseDto(changes: $changes, nextCursor: $nextCursor, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$PullResponseDtoCopyWith<$Res> implements $PullResponseDtoCopyWith<$Res> {
  factory _$PullResponseDtoCopyWith(_PullResponseDto value, $Res Function(_PullResponseDto) _then) = __$PullResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<PulledChangeDto> changes, int nextCursor, bool hasMore
});




}
/// @nodoc
class __$PullResponseDtoCopyWithImpl<$Res>
    implements _$PullResponseDtoCopyWith<$Res> {
  __$PullResponseDtoCopyWithImpl(this._self, this._then);

  final _PullResponseDto _self;
  final $Res Function(_PullResponseDto) _then;

/// Create a copy of PullResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? changes = null,Object? nextCursor = null,Object? hasMore = null,}) {
  return _then(_PullResponseDto(
changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<PulledChangeDto>,nextCursor: null == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RateDto {

 String get currency; num get rate; String get date;
/// Create a copy of RateDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateDtoCopyWith<RateDto> get copyWith => _$RateDtoCopyWithImpl<RateDto>(this as RateDto, _$identity);

  /// Serializes this RateDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RateDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateDto&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.date, _this.date) || other.date == _this.date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RateDto;
  return Object.hash(runtimeType,_this.currency,_this.rate,_this.date);
}

@override
String toString() {
  final _this = this as RateDto;
  return 'RateDto(currency: ${_this.currency}, rate: ${_this.rate}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $RateDtoCopyWith<$Res>  {
  factory $RateDtoCopyWith(RateDto value, $Res Function(RateDto) _then) = _$RateDtoCopyWithImpl;
@useResult
$Res call({
 String currency, num rate, String date
});




}
/// @nodoc
class _$RateDtoCopyWithImpl<$Res>
    implements $RateDtoCopyWith<$Res> {
  _$RateDtoCopyWithImpl(this._self, this._then);

  final RateDto _self;
  final $Res Function(RateDto) _then;

/// Create a copy of RateDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? rate = null,Object? date = null,}) {
  return _then(RateDto(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as num,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RateDto].
extension RateDtoPatterns on RateDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RateDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RateDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RateDto value)  $default,){
final _that = this;
switch (_that) {
case _RateDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RateDto value)?  $default,){
final _that = this;
switch (_that) {
case _RateDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currency,  num rate,  String date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RateDto() when $default != null:
return $default(_that.currency,_that.rate,_that.date);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currency,  num rate,  String date)  $default,) {final _that = this;
switch (_that) {
case _RateDto():
return $default(_that.currency,_that.rate,_that.date);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currency,  num rate,  String date)?  $default,) {final _that = this;
switch (_that) {
case _RateDto() when $default != null:
return $default(_that.currency,_that.rate,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RateDto implements RateDto {
  const _RateDto({required this.currency, required this.rate, required this.date});
  factory _RateDto.fromJson(Map<String, dynamic> json) => _$RateDtoFromJson(json);

@override final  String currency;
@override final  num rate;
@override final  String date;

/// Create a copy of RateDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RateDtoCopyWith<_RateDto> get copyWith => __$RateDtoCopyWithImpl<_RateDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RateDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateDto&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currency,rate,date);
}

@override
String toString() {
    return 'RateDto(currency: $currency, rate: $rate, date: $date)';
}


}

/// @nodoc
abstract mixin class _$RateDtoCopyWith<$Res> implements $RateDtoCopyWith<$Res> {
  factory _$RateDtoCopyWith(_RateDto value, $Res Function(_RateDto) _then) = __$RateDtoCopyWithImpl;
@override @useResult
$Res call({
 String currency, num rate, String date
});




}
/// @nodoc
class __$RateDtoCopyWithImpl<$Res>
    implements _$RateDtoCopyWith<$Res> {
  __$RateDtoCopyWithImpl(this._self, this._then);

  final _RateDto _self;
  final $Res Function(_RateDto) _then;

/// Create a copy of RateDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? rate = null,Object? date = null,}) {
  return _then(_RateDto(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as num,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RatesResponseDto {

 String get baseCurrency; String get date; List<RateDto> get rates;
/// Create a copy of RatesResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatesResponseDtoCopyWith<RatesResponseDto> get copyWith => _$RatesResponseDtoCopyWithImpl<RatesResponseDto>(this as RatesResponseDto, _$identity);

  /// Serializes this RatesResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RatesResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatesResponseDto&&(identical(other.baseCurrency, _this.baseCurrency) || other.baseCurrency == _this.baseCurrency)&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.rates, _this.rates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RatesResponseDto;
  return Object.hash(runtimeType,_this.baseCurrency,_this.date,const DeepCollectionEquality().hash(_this.rates));
}

@override
String toString() {
  final _this = this as RatesResponseDto;
  return 'RatesResponseDto(baseCurrency: ${_this.baseCurrency}, date: ${_this.date}, rates: ${_this.rates})';
}


}

/// @nodoc
abstract mixin class $RatesResponseDtoCopyWith<$Res>  {
  factory $RatesResponseDtoCopyWith(RatesResponseDto value, $Res Function(RatesResponseDto) _then) = _$RatesResponseDtoCopyWithImpl;
@useResult
$Res call({
 String baseCurrency, String date, List<RateDto> rates
});




}
/// @nodoc
class _$RatesResponseDtoCopyWithImpl<$Res>
    implements $RatesResponseDtoCopyWith<$Res> {
  _$RatesResponseDtoCopyWithImpl(this._self, this._then);

  final RatesResponseDto _self;
  final $Res Function(RatesResponseDto) _then;

/// Create a copy of RatesResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseCurrency = null,Object? date = null,Object? rates = null,}) {
  return _then(RatesResponseDto(
baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rates: null == rates ? _self.rates : rates // ignore: cast_nullable_to_non_nullable
as List<RateDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [RatesResponseDto].
extension RatesResponseDtoPatterns on RatesResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatesResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatesResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatesResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _RatesResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatesResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _RatesResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String baseCurrency,  String date,  List<RateDto> rates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatesResponseDto() when $default != null:
return $default(_that.baseCurrency,_that.date,_that.rates);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String baseCurrency,  String date,  List<RateDto> rates)  $default,) {final _that = this;
switch (_that) {
case _RatesResponseDto():
return $default(_that.baseCurrency,_that.date,_that.rates);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String baseCurrency,  String date,  List<RateDto> rates)?  $default,) {final _that = this;
switch (_that) {
case _RatesResponseDto() when $default != null:
return $default(_that.baseCurrency,_that.date,_that.rates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RatesResponseDto implements RatesResponseDto {
  const _RatesResponseDto({required this.baseCurrency, required this.date,  List<RateDto> rates = const []}): _rates = rates;
  factory _RatesResponseDto.fromJson(Map<String, dynamic> json) => _$RatesResponseDtoFromJson(json);

@override final  String baseCurrency;
@override final  String date;
 final  List<RateDto> _rates;
@override@JsonKey() List<RateDto> get rates {
  if (_rates is EqualUnmodifiableListView) return _rates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rates);
}


/// Create a copy of RatesResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatesResponseDtoCopyWith<_RatesResponseDto> get copyWith => __$RatesResponseDtoCopyWithImpl<_RatesResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RatesResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatesResponseDto&&(identical(other.baseCurrency, baseCurrency) || other.baseCurrency == baseCurrency)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.rates, _rates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,baseCurrency,date,const DeepCollectionEquality().hash(_rates));
}

@override
String toString() {
    return 'RatesResponseDto(baseCurrency: $baseCurrency, date: $date, rates: $rates)';
}


}

/// @nodoc
abstract mixin class _$RatesResponseDtoCopyWith<$Res> implements $RatesResponseDtoCopyWith<$Res> {
  factory _$RatesResponseDtoCopyWith(_RatesResponseDto value, $Res Function(_RatesResponseDto) _then) = __$RatesResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String baseCurrency, String date, List<RateDto> rates
});




}
/// @nodoc
class __$RatesResponseDtoCopyWithImpl<$Res>
    implements _$RatesResponseDtoCopyWith<$Res> {
  __$RatesResponseDtoCopyWithImpl(this._self, this._then);

  final _RatesResponseDto _self;
  final $Res Function(_RatesResponseDto) _then;

/// Create a copy of RatesResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseCurrency = null,Object? date = null,Object? rates = null,}) {
  return _then(_RatesResponseDto(
baseCurrency: null == baseCurrency ? _self.baseCurrency : baseCurrency // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,rates: null == rates ? _self._rates : rates // ignore: cast_nullable_to_non_nullable
as List<RateDto>,
  ));
}


}

// dart format on
