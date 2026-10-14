import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/repo/student_info_repository.dart';

import 'student_info_repository_test.dart';

/// 可控时序与可控失败的存储替身。
///
/// [gate] 非空时 save/saveMeta 在生效前挂起，用来把「某个存储操作尚在飞」这段
/// 窗口做成确定性的；[failNext] 模拟一次磁盘写失败。两者都是为了让
/// `BaseNetCachedRepository` 的持久化队列行为可断言：真实 Hive 的时序不可控，
/// 而 `InMemoryStudentInfoStorage` 的方法体在一个微任务内完成，会系统性低估
/// 交错的窗口。
class _Storage implements StudentInfoStorage {
  StudentInfoData? data;
  StudentInfoCacheMeta? meta;

  /// 每次 save/saveMeta 的起止事件，用于断言写入是否真的串行。
  final List<String> log = <String>[];
  int _sequence = 0;
  Completer<void>? gate;
  bool failNext = false;

  @override
  Future<StudentInfoData?> read() async => data;

  @override
  Future<StudentInfoCacheMeta?> readMeta() async => meta;

  @override
  Future<void> save(StudentInfoData value) async {
    final int id = ++_sequence;
    log.add('save#$id 开始');
    if (gate != null) {
      await gate!.future;
    }
    if (failNext) {
      failNext = false;
      log.add('save#$id 失败');
      throw Exception('simulated disk failure');
    }
    log.add('save#$id 完成');
    data = value;
  }

  @override
  Future<void> saveMeta(StudentInfoCacheMeta value) async {
    if (gate != null) {
      await gate!.future;
    }
    meta = value;
  }

  @override
  Future<void> clear() async {
    data = null;
    meta = null;
  }
}

void main() {
  group('BaseNetCachedRepository 持久化队列', () {
    test('两次写入串行：后一次在前一次完成之后才开始', () async {
      final _Storage storage = _Storage()..gate = Completer<void>();
      final StudentInfoRepository repository =
          StudentInfoRepository(storage: storage);

      final Future<StudentInfoData> first = repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildStudentInfo(),
      );
      await Future<void>.delayed(Duration.zero);

      final Future<StudentInfoData> second = repository.refresh(
        now: DateTime(2026, 1, 2),
        fetcher: () async => buildStudentInfo(),
      );
      await Future<void>.delayed(Duration.zero);

      // 第一次写入仍挂在 gate 上，此时第二次不得已经开始。
      expect(storage.log, <String>['save#1 开始'],
          reason: '串行意味着前一次未完成前，后一次不得启动');

      storage.gate!.complete();
      await first;
      await second;
    });

    test('一次写失败后，后续写入仍能落盘', () async {
      final _Storage storage = _Storage()..failNext = true;
      final StudentInfoRepository repository =
          StudentInfoRepository(storage: storage);

      // 第一次写入失败：getOrFetch 本身仍返回数据（内存已缓存），故不 await 队列。
      await repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildStudentInfo(),
      );
      await Future<void>.delayed(Duration.zero);

      await repository.refresh(
        now: DateTime(2026, 1, 2),
        fetcher: () async => buildStudentInfo(deptName: 'After Failure'),
      );

      // getOrFetch / refresh 只等 fetch，不等落盘（持久化是 fire-and-forget），
      // 故显式 flush 后再断言存储内容。
      await repository.flush();
      expect(storage.data?.deptName, 'After Failure',
          reason: '单次磁盘写失败不得堵死后续写入');
    });

    test('一次写失败后 clearCache 仍成功', () async {
      final _Storage storage = _Storage()..failNext = true;
      final StudentInfoRepository repository =
          StudentInfoRepository(storage: storage);

      await repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildStudentInfo(),
      );
      await Future<void>.delayed(Duration.zero);

      // 登出编排串行 await 各仓库的 clearCache，任一抛异常都会中断其后所有
      // 仓库的清理，并把会话留在半登出状态。
      await expectLater(repository.clearCache(), completes);

      expect(storage.data, isNull);
      expect(storage.meta, isNull);
    });

    test('写失败后连续 clearCache 仍成功（登出编排的串行清理）', () async {
      final _Storage first = _Storage()..failNext = true;
      final _Storage second = _Storage();
      final StudentInfoRepository repositoryA =
          StudentInfoRepository(storage: first);
      final StudentInfoRepository repositoryB =
          StudentInfoRepository(storage: second);

      await repositoryA.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildStudentInfo(),
      );
      await Future<void>.delayed(Duration.zero);

      // 模拟 LogoutService.clearSession 的形状：串行 await 多个仓库的 clearCache，
      // 前序仓库有过写失败。任一抛出都会让后续仓库不被清理。
      final List<String> results = <String>[];
      for (final StudentInfoRepository repo in <StudentInfoRepository>[
        repositoryA,
        repositoryB,
      ]) {
        try {
          await repo.clearCache();
          results.add('ok');
        } catch (_) {
          results.add('FAIL');
        }
      }

      expect(results, <String>['ok', 'ok'],
          reason: '前序仓库的写失败不得中断后续仓库的清理');
    });

    test('flush 等待在飞的写入', () async {
      final _Storage storage = _Storage()..gate = Completer<void>();
      final StudentInfoRepository repository =
          StudentInfoRepository(storage: storage);

      await repository.getOrFetch(
        now: DateTime(2026, 1, 1),
        fetcher: () async => buildStudentInfo(),
      );
      await Future<void>.delayed(Duration.zero);

      Future<bool> flushed = repository.flush().then((_) => true);
      await Future<void>.delayed(Duration.zero);
      expect(await flushed.timeout(const Duration(milliseconds: 50),
          onTimeout: () => false), isFalse,
          reason: '写入尚在飞时 flush 不应返回');

      storage.gate!.complete();
      await repository.flush().timeout(const Duration(seconds: 1));
      // 走到这里说明在飞的写入已被等到。
    });
  });
}
