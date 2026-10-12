import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/token_repository.dart';

TokenData _token(String accessToken) {
  return TokenData(
    accessToken: accessToken,
    refreshToken: 'refresh-$accessToken',
    tokenType: 'Bearer',
    scope: 'scope',
    idToken: 'id',
    sessionState: 'state',
    accessTokenExpiresIn: 3600,
    refreshTokenExpiresIn: 7200,
    issuedAt: DateTime.now(),
  );
}

/// 可控时序的存储替身：读取在 [readGate] 未释放前挂起，返回的是读取发起时的快照。
///
/// `InMemoryTokenStorage` 的方法体是同步的，在一个微任务内完成，系统性地低估了
/// 真实存储（Hive 的 openBox 有磁盘 I/O）带来的交错窗口，正是这类竞态被漏掉的原因。
class _GatedStorage implements TokenStorage {
  _GatedStorage(this._delegate);

  final TokenStorage _delegate;
  final Completer<void> readGate = Completer<void>();
  int readCount = 0;

  @override
  Future<TokenData?> read() async {
    readCount += 1;
    final TokenData? snapshot = await _delegate.read();
    await readGate.future;
    return snapshot;
  }

  @override
  Future<void> save(TokenData token) => _delegate.save(token);

  @override
  Future<void> clear() => _delegate.clear();
}

void main() {
  group('TokenRepository 代次契约', () {
    test('写入推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      final int before = repository.generation;

      await repository.saveToken(_token('a'));

      expect(repository.generation, before + 1);
    });

    test('清除推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      await repository.saveToken(_token('a'));
      final int before = repository.generation;

      await repository.clearToken();

      expect(repository.generation, before + 1);
    });

    test('读取不推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      await repository.saveToken(_token('a'));
      final int before = repository.generation;

      await repository.getToken(refreshFromStorage: true);

      expect(repository.generation, before,
          reason: '读取不是状态变更，不应推进代次');
    });
  });

  group('TokenRepository 读取与变更交错', () {
    test('读取期间登出，不得把登出前的令牌装回缓存', () async {
      final _GatedStorage storage = _GatedStorage(InMemoryTokenStorage());
      final TokenRepository repository = TokenRepository(storage: storage);
      await repository.saveToken(_token('old'));

      // 读取发起后挂起，此刻缓存与存储里都是登出前的令牌。
      final Future<TokenData?> pending = repository.getToken(
        refreshFromStorage: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(storage.readCount, 1);

      await repository.clearToken();
      storage.readGate.complete();

      expect(await pending, isNull);
      expect(await repository.getToken(), isNull,
          reason: '读取不得把登出前读到的令牌重新写回缓存');
      expect(await storage.read(), isNull,
          reason: '存储中的令牌也必须已清除');
    });

    test('读取期间重新登录，应返回新令牌而非旧快照', () async {
      final _GatedStorage storage = _GatedStorage(InMemoryTokenStorage());
      final TokenRepository repository = TokenRepository(storage: storage);
      await repository.saveToken(_token('old'));

      final Future<TokenData?> pending = repository.getToken(
        refreshFromStorage: true,
      );
      await Future<void>.delayed(Duration.zero);

      await repository.saveToken(_token('new'));
      storage.readGate.complete();

      expect((await pending)?.accessToken, 'new',
          reason: '期间发生的写入才是权威结果');
    });
  });

  group('TokenRepository saveFromCode2Token', () {
    test('写入推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: InMemoryTokenStorage());
      final int before = repository.generation;

      await repository.saveFromCode2Token(Code2TokenData(
        accessToken: 'a',
        refreshToken: 'r',
        tokenType: 'Bearer',
        scope: 's',
        idToken: 'i',
        sessionState: 'ss',
        notBeforePolicy: 0,
        expiresIn: 3600,
        refreshExpiresIn: 7200,
      ));

      expect(repository.generation, before + 1);
    });
  });
}
