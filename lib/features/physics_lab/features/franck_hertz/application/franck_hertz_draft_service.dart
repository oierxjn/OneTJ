import 'package:onetj/features/physics_lab/features/franck_hertz/models/franck_hertz_draft.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

/// 弗兰克-赫兹实验的草稿存取服务。
///
/// 持有本实验的存储 key，并负责 JSON 序列化与损坏数据防御。
class FranckHertzDraftService {
  FranckHertzDraftService({PhysicsLabDraftRepository? repository})
      : _repository = repository ?? PhysicsLabDraftRepository();

  static const String _key = 'franck_hertz';

  final PhysicsLabDraftRepository _repository;

  Future<FranckHertzDraft?> load() async {
    final String? raw = await _repository.read(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return FranckHertzDraft.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(FranckHertzDraft draft) =>
      _repository.save(_key, draft.toJsonString());
}