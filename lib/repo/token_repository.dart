import 'dart:convert';

import 'package:hive/hive.dart';

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
    final DateTime accessTokenExpiresAt = issuedAt.add(Duration(seconds: accessTokenExpiresIn));
    return DateTime.now().add(skew).isAfter(accessTokenExpiresAt);
  }

  bool isRefreshTokenExpired({Duration skew = Duration.zero}) {
    final DateTime refreshTokenExpiresAt = issuedAt.add(Duration(seconds: refreshTokenExpiresIn));
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

abstract class TokenStorage {
  Future<TokenData?> read();
  Future<void> save(TokenData token);
  Future<void> clear();
}

class HiveTokenStorage implements TokenStorage {
  HiveTokenStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'auth_token';
  static const String _key = 'payload';
  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<TokenData?> read() async {
    final Box<String> box = await _openBox();
    final String? raw = box.get(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return TokenData.fromJson(data);
  }

  @override
  Future<void> save(TokenData token) async {
    final Box<String> box = await _openBox();
    await box.put(_key, jsonEncode(token.toJson()));
  }

  @override
  Future<void> clear() async {
    final Box<String> box = await _openBox();
    await box.delete(_key);
  }
}

class InMemoryTokenStorage implements TokenStorage {
  TokenData? _cache;

  @override
  Future<TokenData?> read() async => _cache;

  @override
  Future<void> save(TokenData token) async {
    _cache = token;
  }

  @override
  Future<void> clear() async {
    _cache = null;
  }
}

/// 用于存储和管理认证令牌的仓库类。
/// 
/// 使用 getInstance 方法获取单例实例。
class TokenRepository {
  TokenRepository._({required TokenStorage storage}) : _storage = storage;

  static TokenRepository? _instance;

  static TokenRepository getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    final TokenRepository repo = TokenRepository._(
      storage: HiveTokenStorage(),
    );
    _instance = repo;
    return repo;
  }

  final TokenStorage _storage;
  TokenData? _cached;

  Future<TokenData?> getToken({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached;
    }
    _cached = await _storage.read();
    return _cached;
  }

  Future<void> saveToken(TokenData token) async {
    _cached = token;
    await _storage.save(token);
  }

  Future<void> saveFromCode2Token(Code2TokenData data, {DateTime? issuedAt}) async {
    final TokenData token = TokenData.fromCode2TokenData(data, now: issuedAt);
    await saveToken(token);
  }

  Future<void> clearToken() async {
    _cached = null;
    await _storage.clear();
  }
}
