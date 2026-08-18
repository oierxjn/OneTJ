import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_draft.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/models/franck_hertz_draft.dart';
import 'package:onetj/features/physics_lab/features/michelson/models/michelson_draft.dart';

void main() {
  group('MichelsonDraft', () {
    test('round-trips through JSON', () {
      final MichelsonDraft draft = MichelsonDraft(
        positions: <String>['50.41310', '', '50.43227'],
      );

      final MichelsonDraft restored = MichelsonDraft.fromJsonString(
        draft.toJsonString(),
      );

      expect(restored.toJsonString(), draft.toJsonString());
    });

    test('falls back to empty positions for missing field', () {
      final MichelsonDraft restored = MichelsonDraft.fromJson(
        const <String, dynamic>{},
      );

      expect(restored.positions, isEmpty);
    });
  });

  group('DiffractionGratingDraft', () {
    test('round-trips through JSON', () {
      final DiffractionGratingDraft draft = DiffractionGratingDraft(
        calibrationTexts: <List<String>>[
          <String>['159 03', '339 03', '197 34', '17 34'],
        ],
        wavelengthTexts: <List<List<String>>>[
          <List<String>>[
            <String>['171 02', '351 02', '186 06', '6 06'],
            <String>['163 13', '343 13', '193 41', '13 41'],
          ],
          <List<String>>[
            <String>['168 26', '348 26', '188 37', '8 37'],
            <String>['157 52', '337 52', '198 37', '18 37'],
          ],
        ],
        referenceWavelengthTexts: <String>['435.84', '585.94'],
        calibrationReferenceText: '546.07',
      );

      final DiffractionGratingDraft restored =
          DiffractionGratingDraft.fromJsonString(draft.toJsonString());

      expect(restored.toJsonString(), draft.toJsonString());
    });

    test('falls back to empty structures for missing fields', () {
      final DiffractionGratingDraft restored = DiffractionGratingDraft.fromJson(
        const <String, dynamic>{},
      );

      expect(restored.calibrationTexts, isEmpty);
      expect(restored.wavelengthTexts, isEmpty);
      expect(restored.referenceWavelengthTexts, isEmpty);
      expect(restored.calibrationReferenceText, isEmpty);
    });
  });

  group('FranckHertzDraft', () {
    test('round-trips through JSON', () {
      final FranckHertzDraft draft = FranckHertzDraft(
        vfText: '2.5',
        vg1kText: '1.5',
        vg2aText: '7.0',
        referenceVoltageText: '11.61',
        rows: const <FranckHertzDraftRow>[
          FranckHertzDraftRow(vg2kText: '0', ipText: '0'),
          FranckHertzDraftRow(vg2kText: '0.5', ipText: '0.002'),
        ],
      );

      final FranckHertzDraft restored = FranckHertzDraft.fromJsonString(
        draft.toJsonString(),
      );

      expect(restored.toJsonString(), draft.toJsonString());
    });

    test('falls back to empty values for missing fields', () {
      final FranckHertzDraft restored = FranckHertzDraft.fromJson(
        const <String, dynamic>{},
      );

      expect(restored.vfText, isEmpty);
      expect(restored.vg1kText, isEmpty);
      expect(restored.vg2aText, isEmpty);
      expect(restored.referenceVoltageText, isEmpty);
      expect(restored.rows, isEmpty);
    });
  });
}