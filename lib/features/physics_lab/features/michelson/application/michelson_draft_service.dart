import 'package:onetj/features/physics_lab/features/michelson/models/michelson_draft.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

/// 迈克尔逊干涉实验的草稿存取服务。
///
/// 持有本实验的存储 key，并负责 JSON 序列化与损坏数据防御。
class MichelsonDraftService {
  MichelsonDraftService({PhysicsLabDraftRepository? repository})
      : _repository = repository ?? PhysicsLabDraftRepository();

  static const String _key = 'michelson';

  final PhysicsLabDraftRepository _repository;

  Future<MichelsonDraft?> load() async {
    final String? raw = await _repository.read(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return MichelsonDraft.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(MichelsonDraft draft) =>
      _repository.save(_key, draft.toJsonString());
}