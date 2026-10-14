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

/// 可控时序的内存存储替身。
///
/// [readGate] 非空时读取在返回前挂起，用来把「加载进行中」这段窗口做成确定性的。
/// [clearIsNoOp] 模拟存储清除失败：数据仍留在盘上。
class _Storage implements TokenStorage {
  TokenData? value;
  int readCount = 0;
  bool clearIsNoOp = false;
  Completer<void>? readGate;

  @override
  Future<TokenData?> read() async {
    readCount += 1;
    final TokenData? snapshot = value;
    if (readGate != null) {
      await readGate!.future;
    }
    return snapshot;
  }

  @override
  Future<void> save(TokenData token) async {
    value = token;
  }

  @override
  Future<void> clear() async {
    if (clearIsNoOp) {
      return;
    }
    value = null;
  }
}

void main() {
  group('TokenRepository 一次性加载', () {
    test('首次读取从存储加载', () async {
      final _Storage storage = _Storage()..value = _token('a');
      final TokenRepository repository = TokenRepository(storage: storage);

      expect((await repository.getToken())?.accessToken, 'a');
      expect(storage.readCount, 1);
    });

    test('之后不再读取存储，只返回内存值', () async {
      final _Storage storage = _Storage()..value = _token('a');
      final TokenRepository repository = TokenRepository(storage: storage);

      await repository.getToken();
      await repository.getToken();
      await repository.getToken();

      expect(storage.readCount, 1, reason: '一次性加载，此后只读内存');
    });

    test('加载期间发生写入：写入的结果才是权威的', () async {
      final _Storage storage = _Storage()
        ..value = _token('old')
        ..readGate = Completer<void>();
      final TokenRepository repository = TokenRepository(storage: storage);

      final Future<TokenData?> pending = repository.getToken();
      await Future<void>.delayed(Duration.zero);
      expect(storage.readCount, 1, reason: '读取已进入挂起状态');

      await repository.saveToken(_token('new'));
      storage.readGate!.complete();

      expect((await pending)?.accessToken, 'new',
          reason: '加载期间发生的写入才是权威结果，不得被加载到的旧快照覆盖');
    });

    test('加载期间发生登出：读取得到 null 而非旧令牌', () async {
      final _Storage storage = _Storage()
        ..value = _token('old')
        ..readGate = Completer<void>();
      final TokenRepository repository = TokenRepository(storage: storage);

      final Future<TokenData?> pending = repository.getToken();
      await Future<void>.delayed(Duration.zero);

      await repository.clearToken();
      storage.readGate!.complete();

      expect(await pending, isNull,
          reason: '登出已把内存置空，加载不得把登出前的令牌装回来');
    });

    test('首次读取前的写入优先于存储旧值', () async {
      final _Storage storage = _Storage()..value = _token('old');
      final TokenRepository repository = TokenRepository(storage: storage);

      await repository.saveToken(_token('new'));

      expect((await repository.getToken())?.accessToken, 'new');
      expect(storage.readCount, 0, reason: '写入即视为已加载，无需再读存储');
    });

    test('登出后即使存储仍有值也不再读回', () async {
      final _Storage storage = _Storage()
        ..value = _token('a')
        ..clearIsNoOp = true;
      final TokenRepository repository = TokenRepository(storage: storage);

      await repository.getToken();
      await repository.clearToken();

      expect(await repository.getToken(), isNull,
          reason: '内存是权威的；若每次都回读存储，清除失败会把令牌复活');
      expect(storage.readCount, 1, reason: '登出后没有理由再读存储');
    });
  });

  group('TokenRepository 代次契约', () {
    test('写入推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: _Storage());
      final int before = repository.generation;

      await repository.saveToken(_token('a'));

      expect(repository.generation, before + 1);
    });

    test('清除推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: _Storage());
      await repository.saveToken(_token('a'));
      final int before = repository.generation;

      await repository.clearToken();

      expect(repository.generation, before + 1);
    });

    test('读取不推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: _Storage()..value = _token('a'));
      final int before = repository.generation;

      await repository.getToken();

      expect(repository.generation, before,
          reason: '读取不是状态变更，不应推进代次');
    });
  });

  group('TokenRepository saveFromCode2Token', () {
    test('写入推进代次', () async {
      final TokenRepository repository =
          TokenRepository(storage: _Storage());
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
