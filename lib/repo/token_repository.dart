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
class TokenRepository {
  TokenRepository({TokenStorage? storage})
      : _storage = storage ?? HiveTokenStorage();

  final TokenStorage _storage;
  TokenData? _cached;

  int _generation = 0;

  /// 令牌代次，每次 [saveToken] / [clearToken] 后自增。
  ///
  /// 读取方可用它判断自己读到的令牌是否已被替换或清除：一次基于旧 refresh
  /// token 起飞的网络刷新，在写回前比对代次即可发现期间发生过变更，从而丢弃
  /// 已过时的结果。
  ///
  /// 计数器与它保护的状态放在一起，任何新增的写入或清除路径都自动受保护。
  /// 读取（[getToken]）不推进代次：它不是状态变更，但它读到的快照可能已经过时，
  /// 因此写入缓存前同样要比对代次。
  int get generation => _generation;

  Future<TokenData?> getToken({bool refreshFromStorage = false}) async {
    if (!refreshFromStorage && _cached != null) {
      return _cached;
    }
    // 读取期间令牌可能被替换或清除。若代次已推进，那次变更的结果才是权威的，
    // 不能用这次读取到的过时值覆盖缓存，否则会把登出前的令牌重新装回来。
    final int generationBeforeRead = _generation;
    final TokenData? stored = await _storage.read();
    if (_generation == generationBeforeRead) {
      _cached = stored;
    }
    return _cached;
  }

  Future<void> saveToken(TokenData token) async {
    _cached = token;
    _generation += 1;
    await _storage.save(token);
  }

  Future<void> saveFromCode2Token(Code2TokenData data,
      {DateTime? issuedAt}) async {
    final TokenData token = TokenData.fromCode2TokenData(data, now: issuedAt);
    await saveToken(token);
  }

  Future<void> clearToken() async {
    _cached = null;
    _generation += 1;
    await _storage.clear();
  }
}
