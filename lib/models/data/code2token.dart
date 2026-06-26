import 'package:json_annotation/json_annotation.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/log_level.dart';

part 'code2token.g.dart';

/// 标识 [Code2TokenData.fromJson] 解析时出问题的 JSON 字段。
enum Code2TokenField {
  /// [Code2TokenData.accessToken] — JSON key: `access_token`
  accessToken,

  /// [Code2TokenData.tokenType] — JSON key: `token_type`
  tokenType,

  /// [Code2TokenData.expiresIn] — JSON key: `expires_in`
  expiresIn,

  /// [Code2TokenData.refreshToken] — JSON key: `refresh_token`
  refreshToken,

  /// [Code2TokenData.refreshExpiresIn] — JSON key: `refresh_expires_in`
  refreshExpiresIn,

  /// [Code2TokenData.scope] — JSON key: `scope`
  scope,

  /// [Code2TokenData.sessionState] — JSON key: `session_state`
  sessionState,
}

/// 字段解析失败的原因。
enum Code2TokenParseReason {
  /// 字段缺失（值为 null）
  missing,

  /// 字段类型不匹配
  typeMismatch,
}

/// [Code2TokenData.fromJson] 解析时抛出的异常，携带具体字段名和原因。
///
/// 相比泛泛的 `type 'Null' is not a subtype of type 'String'`，
/// 调用方可以直接通过 [field] 和 [reason] 定位问题。
class Code2TokenParseException extends AppException {
  static const String errorCode = 'CODE2TOKEN_PARSE_ERROR';

  Code2TokenParseException({
    required this.field,
    required this.reason,
    required this.rawJson,
  }) : super(
          errorCode,
          'Code2Token parse failed: ${reason.name} on field "${field.name}"',
          level: AppLogLevel.error,
        );

  /// 出问题的字段
  final Code2TokenField field;

  /// 失败原因
  final Code2TokenParseReason reason;

  /// 原始 JSON 响应（便于调试）
  final Map<String, dynamic> rawJson;

  @override
  String toString() {
    final String jsonKey = _jsonKeyForField(field);
    return 'Code2TokenParseException: $reason '
        'on field "${field.name}" (JSON key: "$jsonKey") '
        'in response: $rawJson';
  }

  /// 将枚举值映射回 JSON key，方便报错信息阅读。
  static String _jsonKeyForField(Code2TokenField f) {
    switch (f) {
      case Code2TokenField.accessToken:
        return 'access_token';
      case Code2TokenField.tokenType:
        return 'token_type';
      case Code2TokenField.expiresIn:
        return 'expires_in';
      case Code2TokenField.refreshToken:
        return 'refresh_token';
      case Code2TokenField.refreshExpiresIn:
        return 'refresh_expires_in';
      case Code2TokenField.scope:
        return 'scope';
      case Code2TokenField.sessionState:
        return 'session_state';
    }
  }
}

@JsonSerializable()
class Code2TokenData {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'refresh_expires_in')
  final int refreshExpiresIn;

  @JsonKey(name: 'not-before-policy', defaultValue: 0)
  final int notBeforePolicy;

  @JsonKey(name: 'id_token', defaultValue: '')
  final String idToken;

  final String scope;

  @JsonKey(name: 'session_state')
  final String sessionState;

  const Code2TokenData({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.notBeforePolicy,
    required this.idToken,
    required this.scope,
    required this.sessionState,
  });

  /// 自定义 JSON 解析，对每个必填字段做 null 检查，
  /// 缺失时抛出 [Code2TokenParseException] 指明具体字段名。
  factory Code2TokenData.fromJson(Map<String, dynamic> json) {
    T required<T extends Object>(Code2TokenField field, String jsonKey) {
      final dynamic value = json[jsonKey];
      if (value == null) {
        throw Code2TokenParseException(
          field: field,
          reason: Code2TokenParseReason.missing,
          rawJson: json,
        );
      }
      if (value is! T) {
        throw Code2TokenParseException(
          field: field,
          reason: Code2TokenParseReason.typeMismatch,
          rawJson: json,
        );
      }
      return value;
    }

    return Code2TokenData(
      accessToken: required<String>(
        Code2TokenField.accessToken,
        'access_token',
      ),
      tokenType: required<String>(
        Code2TokenField.tokenType,
        'token_type',
      ),
      expiresIn: required<num>(
        Code2TokenField.expiresIn,
        'expires_in',
      ).toInt(),
      refreshToken: required<String>(
        Code2TokenField.refreshToken,
        'refresh_token',
      ),
      refreshExpiresIn: required<num>(
        Code2TokenField.refreshExpiresIn,
        'refresh_expires_in',
      ).toInt(),
      notBeforePolicy:
          (json['not-before-policy'] as num?)?.toInt() ?? 0,
      idToken: (json['id_token'] as String?) ?? '',
      scope: required<String>(
        Code2TokenField.scope,
        'scope',
      ),
      sessionState: required<String>(
        Code2TokenField.sessionState,
        'session_state',
      ),
    );
  }

  Map<String, dynamic> toJson() => _$Code2TokenDataToJson(this);
}