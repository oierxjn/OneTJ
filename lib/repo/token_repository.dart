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
/// 交错，任何比对型守护都补不上写入尚在飞的那段窗口。
///
/// 派生写入（刷新结果）必须走 [saveRefreshedToken] 的 CAS：参与者由签名强制，
/// 不存在「新增了一条写入路径却忘了比对」的可能。用户的决策（登录、登出）
/// 无条件生效，永远压倒在飞的派生写入。
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

  /// 存储写入链，链头永远是错误自由的。
  ///
  /// 存储操作必须串行：一次刷新通过 CAS 之后 [_storage.save] 才落盘，用户可能
  /// 在此期间登出；若两次写乱序，存储里会留下已登出的令牌，下次启动又会把用户
  /// 判定为已登录。链头为何只留吞错后的版本，详见 [_enqueueStorage]。
  Future<void> _storageChain = Future<void>.value();

  /// 把一次存储操作排到写入链末尾，返回它自身的完成期。
  ///
  /// 返回的是 [operation] 的真实结果，失败照常抛给调用方；链头只保存吞错后的
  /// 版本，因此单次失败不会堵死后续操作——刻意不做「前一个失败就整体丢弃」的
  /// 短路。
  ///
  /// 不变式：链头永远错误自由，所以入队时无需再防御前一个链接的错误。
  ///
  /// 注意 [operation] 必须在 `then` 内部调用。若在外部先把 future 构造出来再
  /// 链接，存储操作当下就已启动，串行便形同虚设。
  Future<void> _enqueueStorage(Future<void> Function() operation) {
    final Future<void> result = _storageChain.then((_) => operation());
    _storageChain = result.catchError((_) {});
    return result;
  }

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

  /// 判断指定 access token 是否仍属于当前内存会话。
  bool isCurrentAccessToken(String accessToken) {
    return _cached?.accessToken == accessToken;
  }

  /// 判断指定 refresh token 是否仍属于当前内存会话。
  bool isCurrentRefreshToken(String refreshToken) {
    return _cached?.refreshToken == refreshToken;
  }

  /// 登录换来的令牌：无条件写入。
  ///
  /// 用户的登录决策是权威的，压倒在飞的刷新结果——由 [saveRefreshedToken] 的
  /// CAS 自然拦截（[_cached] 已换成新令牌，比对必然失败）。
  Future<void> saveToken(TokenData token) async {
    _cached = token;
    _loaded = true;
    await _enqueueStorage(() => _storage.save(token));
  }

  Future<void> saveFromCode2Token(Code2TokenData data,
      {DateTime? issuedAt}) async {
    final TokenData token = TokenData.fromCode2TokenData(data, now: issuedAt);
    await saveToken(token);
  }

  /// 以一次刷新的结果覆盖令牌，但仅当这次刷新基于的 refresh token 仍是当前令牌。
  ///
  /// 返回 false 表示期间令牌被替换（重新登录）或清除（登出），结果作废：那次
  /// 刷新基于的 refresh token 已被服务端单次轮换作废，写回去等于用旧会话覆盖
  /// 新会话。
  ///
  /// 比对与 [_cached] 的提交在同一段同步代码里，中间没有 await，在 Dart 的单
  /// 线程模型下是原子的，因此不存在「比对通过、提交前又被改写」的窗口。
  Future<bool> saveRefreshedToken(
    TokenData token, {
    required String refreshTokenUsed,
  }) async {
    if (_cached?.refreshToken != refreshTokenUsed) {
      return false;
    }
    _cached = token;
    await _enqueueStorage(() => _storage.save(token));
    return true;
  }

  /// 登出：无条件清除。
  ///
  /// 用户的登出决策永远压倒在飞的派生写入——[_cached] 置空之后，任何在飞的
  /// [saveRefreshedToken] 比对都会失败。
  Future<void> clearToken() async {
    _cached = null;
    _loaded = true;
    await _enqueueStorage(() => _storage.clear());
  }
}
