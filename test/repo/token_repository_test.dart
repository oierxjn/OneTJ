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
/// [readGate] / [saveGate] 非空时对应操作在生效前挂起，用来把「某个存储操作
/// 尚在飞」这段窗口做成确定性的。[clearIsNoOp] 模拟存储清除失败，
/// [failNextSave] 模拟存储写入失败：仓库不能依赖存储操作成功来维持自身一致。
class _Storage implements TokenStorage {
  TokenData? value;
  int readCount = 0;
  bool clearIsNoOp = false;
  bool failNextSave = false;
  Completer<void>? readGate;
  Completer<void>? saveGate;

  /// 存储操作的落盘序号，用于断言串行顺序。
  int saveOrder = 0;
  int clearOrder = 0;
  int _opCount = 0;

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
    if (saveGate != null) {
      await saveGate!.future;
    }
    if (failNextSave) {
      failNextSave = false;
      throw Exception('simulated storage failure');
    }
    value = token;
    _opCount += 1;
    saveOrder = _opCount;
  }

  @override
  Future<void> clear() async {
    if (clearIsNoOp) {
      return;
    }
    value = null;
    _opCount += 1;
    clearOrder = _opCount;
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

  group('TokenRepository saveRefreshedToken', () {
    test('基于当前 refresh token 时写入', () async {
      final TokenRepository repository = TokenRepository(storage: _Storage());
      await repository.saveToken(_token('a'));

      final bool applied = await repository.saveRefreshedToken(
        _token('a2'),
        refreshTokenUsed: 'refresh-a',
      );

      expect(applied, isTrue);
      expect((await repository.getToken())?.accessToken, 'a2');
    });

    test('期间令牌被替换：不写回', () async {
      final TokenRepository repository = TokenRepository(storage: _Storage());
      await repository.saveToken(_token('a'));
      await repository.saveToken(_token('b'));

      final bool applied = await repository.saveRefreshedToken(
        _token('stale'),
        refreshTokenUsed: 'refresh-a',
      );

      expect(applied, isFalse);
      expect((await repository.getToken())?.accessToken, 'b',
          reason: '陈旧的刷新结果不得覆盖新登录的令牌');
    });

    test('期间令牌被清除：不写回', () async {
      final TokenRepository repository = TokenRepository(storage: _Storage());
      await repository.saveToken(_token('a'));
      await repository.clearToken();

      final bool applied = await repository.saveRefreshedToken(
        _token('resurrected'),
        refreshTokenUsed: 'refresh-a',
      );

      expect(applied, isFalse);
      expect(await repository.getToken(), isNull);
    });

    test('尚未加载时拒绝写入', () async {
      final TokenRepository repository = TokenRepository(storage: _Storage());

      final bool applied = await repository.saveRefreshedToken(
        _token('a'),
        refreshTokenUsed: 'refresh-a',
      );

      expect(applied, isFalse,
          reason: '内存为空说明没有会话，不能凭一次刷新凭空造出一个');
    });
  });

  group('TokenRepository 存储写入串行', () {
    test('登出排在前一次写入之后落盘', () async {
      final _Storage storage = _Storage()..saveGate = Completer<void>();
      final TokenRepository repository = TokenRepository(storage: storage);

      // 写入已提交内存、正挂在存储队列上，此时用户登出。
      final Future<void> saveDone = repository.saveToken(_token('new'));
      final Future<void> clearDone = repository.clearToken();
      storage.saveGate!.complete();
      await saveDone;
      await clearDone;

      expect(await repository.getToken(), isNull, reason: '内存上登出优先');
      expect(storage.value, isNull,
          reason: '存储上清除也必须排在前一次写入之后，否则令牌会留在盘上');
      expect(storage.clearOrder, greaterThan(storage.saveOrder));
    });

    test('存储写入失败不堵死后续操作', () async {
      final _Storage storage = _Storage()..failNextSave = true;
      final TokenRepository repository = TokenRepository(storage: storage);

      await expectLater(
        repository.saveToken(_token('a')),
        throwsA(isA<Exception>()),
      );

      await repository.clearToken();
      expect(storage.value, isNull, reason: '队列在上一次失败之后仍然可用');
    });
  });

  group('TokenRepository saveFromCode2Token', () {
    test('写入令牌', () async {
      final TokenRepository repository = TokenRepository(storage: _Storage());

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

      expect((await repository.getToken())?.accessToken, 'a');
    });
  });
}
