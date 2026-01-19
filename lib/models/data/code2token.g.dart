// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code2token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Code2TokenData _$Code2TokenDataFromJson(Map<String, dynamic> json) =>
    Code2TokenData(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      refreshToken: json['refresh_token'] as String,
      refreshExpiresIn: (json['refresh_expires_in'] as num).toInt(),
      notBeforePolicy: (json['not-before-policy'] as num?)?.toInt() ?? 0,
      idToken: json['id_token'] as String? ?? '',
      scope: json['scope'] as String,
      sessionState: json['session_state'] as String,
    );

Map<String, dynamic> _$Code2TokenDataToJson(Code2TokenData instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'refresh_token': instance.refreshToken,
      'refresh_expires_in': instance.refreshExpiresIn,
      'not-before-policy': instance.notBeforePolicy,
      'id_token': instance.idToken,
      'scope': instance.scope,
      'session_state': instance.sessionState,
    };
