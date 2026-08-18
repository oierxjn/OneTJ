import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_draft.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

/// 光栅衍射实验的草稿存取服务。
///
/// 持有本实验的存储 key，并负责 JSON 序列化与损坏数据防御。
class DiffractionGratingDraftService {
  DiffractionGratingDraftService({PhysicsLabDraftRepository? repository})
      : _repository = repository ?? PhysicsLabDraftRepository();

  static const String _key = 'diffraction_grating';

  final PhysicsLabDraftRepository _repository;

  Future<DiffractionGratingDraft?> load() async {
    final String? raw = await _repository.read(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return DiffractionGratingDraft.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(DiffractionGratingDraft draft) =>
      _repository.save(_key, draft.toJsonString());
}