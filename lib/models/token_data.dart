import 'package:onetj/models/data/code2token.dart';

class TokenData {
  TokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.scope,
    required this.idToken,
    required this.sessionState,
    required this.accessTokenExpiresIn,
    required this.refreshTokenExpiresIn,
    required this.issuedAt,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String scope;
  final String idToken;
  final String sessionState;
  final int accessTokenExpiresIn;
  final int refreshTokenExpiresIn;
  final DateTime issuedAt;

  bool isAccessTokenExpired({Duration skew = Duration.zero}) {
    final DateTime accessTokenExpiresAt =
        issuedAt.add(Duration(seconds: accessTokenExpiresIn));
    return DateTime.now().add(skew).isAfter(accessTokenExpiresAt);
  }

  bool isRefreshTokenExpired({Duration skew = Duration.zero}) {
    final DateTime refreshTokenExpiresAt =
        issuedAt.add(Duration(seconds: refreshTokenExpiresIn));
    return DateTime.now().add(skew).isAfter(refreshTokenExpiresAt);
  }

  factory TokenData.fromCode2TokenData(Code2TokenData data, {DateTime? now}) {
    final DateTime baseTime = now ?? DateTime.now();
    return TokenData(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      tokenType: data.tokenType,
      scope: data.scope,
      idToken: data.idToken,
      sessionState: data.sessionState,
      accessTokenExpiresIn: data.expiresIn,
      refreshTokenExpiresIn: data.refreshExpiresIn,
      issuedAt: baseTime,
    );
  }

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      scope: json['scope'] as String,
      idToken: json['idToken'] as String,
      sessionState: json['sessionState'] as String,
      accessTokenExpiresIn: json['accessTokenExpiresIn'] as int,
      refreshTokenExpiresIn: json['refreshTokenExpiresIn'] as int,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'scope': scope,
      'idToken': idToken,
      'sessionState': sessionState,
      'accessTokenExpiresIn': accessTokenExpiresIn,
      'refreshTokenExpiresIn': refreshTokenExpiresIn,
      'issuedAt': issuedAt.toIso8601String(),
    };
  }
}
