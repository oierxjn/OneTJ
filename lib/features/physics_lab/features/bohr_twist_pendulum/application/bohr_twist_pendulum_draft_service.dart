import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/models/bohr_twist_pendulum_draft.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

/// 波尔扭摆实验的草稿存取服务。
///
/// 持有本实验的存储 key，并负责 JSON 序列化与损坏数据防御。
class BohrTwistPendulumDraftService {
  BohrTwistPendulumDraftService({PhysicsLabDraftRepository? repository})
      : _repository = repository ?? PhysicsLabDraftRepository();

  static const String _key = 'bohr_twist_pendulum';

  final PhysicsLabDraftRepository _repository;

  Future<BohrTwistPendulumDraft?> load() async {
    final String? raw = await _repository.read(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return BohrTwistPendulumDraft.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(BohrTwistPendulumDraft draft) =>
      _repository.save(_key, draft.toJsonString());
}
