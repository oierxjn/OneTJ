import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

void main() {
  group('PhysicsLabDraftRepository', () {
    late InMemoryPhysicsLabDraftStorage storage;
    late PhysicsLabDraftRepository repository;

    setUp(() {
      storage = InMemoryPhysicsLabDraftStorage();
      repository = PhysicsLabDraftRepository(storage: storage);
    });

    test('returns null before any value is saved', () async {
      expect(await repository.read('michelson'), isNull);
    });

    test('stores and retrieves raw string values by key', () async {
      await repository.save('michelson', '{"positions":["1.0"]}');
      await repository.save('diffraction_grating', 'raw-json');

      expect(await repository.read('michelson'), '{"positions":["1.0"]}');
      expect(await repository.read('diffraction_grating'), 'raw-json');
      expect(await repository.read('missing'), isNull);
    });

    test('overwrites an existing key', () async {
      await repository.save('michelson', 'first');
      await repository.save('michelson', 'second');

      expect(await repository.read('michelson'), 'second');
    });
  });
}