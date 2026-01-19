import 'package:json_annotation/json_annotation.dart';

part 'code2token.g.dart';

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

  factory Code2TokenData.fromJson(Map<String, dynamic> json) =>
      _$Code2TokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$Code2TokenDataToJson(this);
}
