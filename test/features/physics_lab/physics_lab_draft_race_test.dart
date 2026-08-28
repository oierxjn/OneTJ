import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/draft_save_coordinator.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/application/bohr_twist_pendulum_draft_service.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/view_models/bohr_twist_pendulum_view_model.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/application/diffraction_grating_draft_service.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/view_models/diffraction_grating_view_model.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/application/franck_hertz_draft_service.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/view_models/franck_hertz_view_model.dart';
import 'package:onetj/features/physics_lab/features/michelson/application/michelson_draft_service.dart';
import 'package:onetj/features/physics_lab/features/michelson/view_models/michelson_interferometer_view_model.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

/// 可人为控制 read / save 放行时机的存储测试替身。
///
/// - [readGate] 非空时，`read` 会等待放行，用于模拟慢加载。
/// - 每次 `save` 都会新增一个 [Completer]，由测试按需 [releaseSave]，
///   用于模拟慢写入 / 乱序完成。
class GatedDraftStorage implements PhysicsLabDraftStorage {
  final Map<String, String> values = <String, String>{};
  Completer<void>? readGate;
  final List<Completer<void>> saveGates = <Completer<void>>[];

  @override
  Future<String?> read(String key) async {
    final Completer<void>? gate = readGate;
    if (gate != null) {
      await gate.future;
    }
    return values[key];
  }

  @override
  Future<void> save(String key, String value) {
    final Completer<void> gate = Completer<void>();
    saveGates.add(gate);
    return gate.future.then((_) {
      values[key] = value;
    });
  }

  void releaseSave(int index) {
    saveGates[index].complete();
  }
}

/// 反复放行所有未完成的 save 直到没有新的写入产生。
Future<void> flushSaves(GatedDraftStorage storage) async {
  while (true) {
    final List<Completer<void>> pending = storage.saveGates
        .where((Completer<void> gate) => !gate.isCompleted)
        .toList();
    if (pending.isEmpty) {
      return;
    }
    for (final Completer<void> gate in pending) {
      gate.complete();
    }
    await pumpEventQueue();
  }
}

void main() {
  group('DraftSaveCoordinator', () {
    test('串行化写入并合并到最新状态', () async {
      final List<String> writes = <String>[];
      final List<Completer<void>> gates = <Completer<void>>[];
      String current = '';
      final DraftSaveCoordinator coordinator = DraftSaveCoordinator(() {
        writes.add(current);
        final Completer<void> gate = Completer<void>();
        gates.add(gate);
        return gate.future;
      });

      current = 'A';
      coordinator.markEdited();
      expect(gates, hasLength(1));

      current = 'B';
      coordinator.markEdited();
      expect(gates, hasLength(1), reason: '写入在途时不应并发启动第二个写入');

      gates[0].complete();
      await pumpEventQueue();
      expect(gates, hasLength(2), reason: '第一轮完成后应补写最新快照');

      gates[1].complete();
      await pumpEventQueue();

      expect(writes, <String>['A', 'B']);
    });

    test('写入异常被吞掉，不产生未处理错误且不死循环', () async {
      int calls = 0;
      final DraftSaveCoordinator coordinator = DraftSaveCoordinator(() async {
        calls += 1;
        throw StateError('boom');
      });

      coordinator.markEdited();
      await pumpEventQueue();

      expect(calls, 1);
      expect(coordinator.editVersion, 1);
    });
  });

  group('迟到的 load 不覆盖本地新输入', () {
    test('MichelsonInterferometerViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final MichelsonDraftService service =
          MichelsonDraftService(repository: repository);

      final MichelsonInterferometerViewModel seed =
          MichelsonInterferometerViewModel(draftService: service);
      seed.updatePositionText(0, '1.0');
      await flushSaves(storage);
      seed.dispose();

      storage.readGate = Completer<void>();
      final MichelsonInterferometerViewModel vm =
          MichelsonInterferometerViewModel(draftService: service);
      final Future<void> loadFuture = vm.load();
      vm.updatePositionText(0, '9.9');

      storage.readGate!.complete();
      await loadFuture;

      expect(vm.positionTexts[0], '9.9');
      await flushSaves(storage);
      vm.dispose();
    });

    test('DiffractionGratingViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final DiffractionGratingDraftService service =
          DiffractionGratingDraftService(repository: repository);

      final DiffractionGratingViewModel seed =
          DiffractionGratingViewModel(draftService: service);
      seed.updateCalibrationReferenceText('111.11');
      await flushSaves(storage);
      seed.dispose();

      storage.readGate = Completer<void>();
      final DiffractionGratingViewModel vm =
          DiffractionGratingViewModel(draftService: service);
      final Future<void> loadFuture = vm.load();
      vm.updateCalibrationReferenceText('999.99');

      storage.readGate!.complete();
      await loadFuture;

      expect(vm.calibrationReferenceText, '999.99');
      await flushSaves(storage);
      vm.dispose();
    });

    test('FranckHertzViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final FranckHertzDraftService service =
          FranckHertzDraftService(repository: repository);

      final FranckHertzViewModel seed =
          FranckHertzViewModel(draftService: service);
      seed.updateVfText('1.1');
      await flushSaves(storage);
      seed.dispose();

      storage.readGate = Completer<void>();
      final FranckHertzViewModel vm =
          FranckHertzViewModel(draftService: service);
      final Future<void> loadFuture = vm.load();
      vm.updateVfText('9.9');

      storage.readGate!.complete();
      await loadFuture;

      expect(vm.metadata.vfText, '9.9');
      await flushSaves(storage);
      vm.dispose();
    });

    test('BohrTwistPendulumViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final BohrTwistPendulumDraftService service =
          BohrTwistPendulumDraftService(repository: repository);

      final BohrTwistPendulumViewModel seed =
          BohrTwistPendulumViewModel(draftService: service);
      seed.updatePeriodText('1.1');
      await flushSaves(storage);
      seed.dispose();

      storage.readGate = Completer<void>();
      final BohrTwistPendulumViewModel vm =
          BohrTwistPendulumViewModel(draftService: service);
      final Future<void> loadFuture = vm.load();
      vm.updatePeriodText('9.9');

      storage.readGate!.complete();
      await loadFuture;

      expect(vm.periodText, '9.9');
      await flushSaves(storage);
      vm.dispose();
    });
  });

  group('保存串行化，最终恢复的是最新编辑', () {
    test('MichelsonInterferometerViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final MichelsonDraftService service =
          MichelsonDraftService(repository: repository);

      final MichelsonInterferometerViewModel vm =
          MichelsonInterferometerViewModel(draftService: service);
      vm.updatePositionText(0, '1.0');
      expect(storage.saveGates, hasLength(1));

      vm.updatePositionText(1, '2.0');
      expect(storage.saveGates, hasLength(1),
          reason: '写入在途时不应并发启动第二个写入');

      storage.releaseSave(0);
      await pumpEventQueue();
      expect(storage.saveGates, hasLength(2));

      storage.releaseSave(1);
      await pumpEventQueue();

      final MichelsonInterferometerViewModel restore =
          MichelsonInterferometerViewModel(draftService: service);
      await restore.load();
      expect(restore.positionTexts[0], '1.0');
      expect(restore.positionTexts[1], '2.0');
      expect(restore.positionTexts[2], isEmpty);

      vm.dispose();
      restore.dispose();
    });

    test('DiffractionGratingViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final DiffractionGratingDraftService service =
          DiffractionGratingDraftService(repository: repository);

      final DiffractionGratingViewModel vm =
          DiffractionGratingViewModel(draftService: service);
      vm.updateCalibrationReferenceText('111.11');
      expect(storage.saveGates, hasLength(1));

      vm.updateCalibrationReading(0, 0, '159 03');
      expect(storage.saveGates, hasLength(1));

      storage.releaseSave(0);
      await pumpEventQueue();
      expect(storage.saveGates, hasLength(2));

      storage.releaseSave(1);
      await pumpEventQueue();

      final DiffractionGratingViewModel restore =
          DiffractionGratingViewModel(draftService: service);
      await restore.load();
      expect(restore.calibrationReferenceText, '111.11');
      expect(restore.calibrationTexts[0][0], '159 03');

      vm.dispose();
      restore.dispose();
    });

    test('FranckHertzViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final FranckHertzDraftService service =
          FranckHertzDraftService(repository: repository);

      final FranckHertzViewModel vm =
          FranckHertzViewModel(draftService: service);
      vm.updateVfText('2.5');
      expect(storage.saveGates, hasLength(1));

      vm.updateRowVg2kText(0, '12.0');
      expect(storage.saveGates, hasLength(1));

      storage.releaseSave(0);
      await pumpEventQueue();
      expect(storage.saveGates, hasLength(2));

      storage.releaseSave(1);
      await pumpEventQueue();

      final FranckHertzViewModel restore =
          FranckHertzViewModel(draftService: service);
      await restore.load();
      expect(restore.metadata.vfText, '2.5');
      expect(restore.rows[0].vg2kText, '12.0');

      vm.dispose();
      restore.dispose();
    });

    test('BohrTwistPendulumViewModel', () async {
      final GatedDraftStorage storage = GatedDraftStorage();
      final PhysicsLabDraftRepository repository =
          PhysicsLabDraftRepository(storage: storage);
      final BohrTwistPendulumDraftService service =
          BohrTwistPendulumDraftService(repository: repository);

      final BohrTwistPendulumViewModel vm =
          BohrTwistPendulumViewModel(draftService: service);
      vm.updatePeriodText('1.6');
      expect(storage.saveGates, hasLength(1));

      vm.updatePeriodTableText('1 100 1.5');
      expect(storage.saveGates, hasLength(1));

      storage.releaseSave(0);
      await pumpEventQueue();
      expect(storage.saveGates, hasLength(2));

      storage.releaseSave(1);
      await pumpEventQueue();

      final BohrTwistPendulumViewModel restore =
          BohrTwistPendulumViewModel(draftService: service);
      await restore.load();
      expect(restore.periodText, '1.6');
      expect(restore.periodTableText, '1 100 1.5');

      vm.dispose();
      restore.dispose();
    });
  });
}