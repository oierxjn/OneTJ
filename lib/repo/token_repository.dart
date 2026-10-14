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
/// 可变状态只有两处：一次性的存储加载，以及此后的内存值 [_cached]。运行期
/// 读取不再触碰存储——否则「读到旧值」与「存储写尚未落盘」这两个延迟会互相
/// 交错，代次计数只能覆盖「读取期间已完成的变更」，补不上写入尚在飞的那段窗口。
class TokenRepository {
  TokenRepository({TokenStorage? storage})
      : _storage = storage ?? HiveTokenStorage();

  final TokenStorage _storage;
  TokenData? _cached;

  /// 是否已从存储加载过。
  ///
  /// 兼任两职：既保证只加载一次，也用来检测加载期间的并发写入——写入方会把
  /// 它一并置位，于是加载完成时复判一次即可丢弃过时快照。
  bool _loaded = false;

  int _generation = 0;

  /// 令牌代次，每次 [saveToken] / [clearToken] 后自增。
  ///
  /// 读取方可用它判断自己读到的令牌是否已被替换或清除：一次基于旧 refresh
  /// token 起飞的网络刷新，在写回前比对代次即可发现期间发生过变更，从而丢弃
  /// 已过时的结果。
  int get generation => _generation;

  /// 读取当前令牌。
  ///
  /// 首次调用从存储加载；此后一律返回内存值（可能为 null，表示已登出），不再
  /// 读取存储。启动时那次加载发生在任何并发写者出现之前——路由守卫在会话
  /// 状态为 unknown 期间把用户停在启动页，登录与登出都不可能发生。
  ///
  /// 本类不提供「强制重读存储」：那会让读取结果可能比已有缓存更旧，是制造竞态
  /// 的入口而不是便利。确有重载需要时应显式新增方法。
  Future<TokenData?> getToken() async {
    if (_loaded) {
      return _cached;
    }
    final TokenData? stored = await _storage.read();
    // 加载期间可能发生过写入或清除，而写入方已把 [_loaded] 一并置位。那次变更
    // 才是权威结果，不能用加载到的旧快照覆盖它。
    if (!_loaded) {
      _cached = stored;
      _loaded = true;
    }
    return _cached;
  }

  Future<void> saveToken(TokenData token) async {
    _cached = token;
    _loaded = true;
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
    _loaded = true;
    _generation += 1;
    await _storage.clear();
  }
}
