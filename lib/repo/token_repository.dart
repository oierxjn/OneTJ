import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/models/token_data.dart';

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
/// 通过 `appLocator<TokenRepository>()` 获取实例。
class TokenRepository {
  TokenRepository({TokenStorage? storage})
      : _storage = storage ?? HiveTokenStorage();

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

  Future<void> saveFromCode2Token(Code2TokenData data,
      {DateTime? issuedAt}) async {
    final TokenData token = TokenData.fromCode2TokenData(data, now: issuedAt);
    await saveToken(token);
  }

  Future<void> clearToken() async {
    _cached = null;
    await _storage.clear();
  }
}
