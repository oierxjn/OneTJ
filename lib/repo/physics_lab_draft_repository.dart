import 'package:hive/hive.dart';

/// 物理实验草稿的存储抽象。
///
/// 提供 [HivePhysicsLabDraftStorage]（生产）和
/// [InMemoryPhysicsLabDraftStorage]（测试）两种实现。
abstract class PhysicsLabDraftStorage {
  Future<String?> read(String key);
  Future<void> save(String key, String value);
}

/// 基于 Hive 的物理实验草稿存储。
class HivePhysicsLabDraftStorage implements PhysicsLabDraftStorage {
  HivePhysicsLabDraftStorage({HiveInterface? hive}) : _hive = hive ?? Hive;

  static const String _boxName = 'physics_lab_drafts';

  final HiveInterface _hive;

  Future<Box<String>> _openBox() async {
    if (_hive.isBoxOpen(_boxName)) {
      return _hive.box<String>(_boxName);
    }
    return _hive.openBox<String>(_boxName);
  }

  @override
  Future<String?> read(String key) async {
    final Box<String> box = await _openBox();
    return box.get(key);
  }

  @override
  Future<void> save(String key, String value) async {
    final Box<String> box = await _openBox();
    await box.put(key, value);
  }
}

/// 内存中的物理实验草稿存储（用于测试）。
class InMemoryPhysicsLabDraftStorage implements PhysicsLabDraftStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> save(String key, String value) async {
    _values[key] = value;
  }
}

/// 物理实验草稿的通用键值仓库。
///
/// 只负责按 key 读写原始字符串，不感知具体实验；key 的语义与 JSON
/// 序列化由各实验的 application service 负责。
class PhysicsLabDraftRepository {
  PhysicsLabDraftRepository({PhysicsLabDraftStorage? storage})
      : _storage = storage ?? HivePhysicsLabDraftStorage();

  final PhysicsLabDraftStorage _storage;

  Future<String?> read(String key) => _storage.read(key);

  Future<void> save(String key, String value) => _storage.save(key, value);
}