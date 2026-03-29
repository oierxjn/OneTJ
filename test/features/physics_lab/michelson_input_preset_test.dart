import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/michelson/models/michelson_input_preset.dart';
import 'package:onetj/features/physics_lab/features/michelson/models/michelson_input_preset_exception.dart';
import 'package:onetj/features/physics_lab/features/michelson/view_models/michelson_interferometer_view_model.dart';

void main() {
  group('MichelsonInputPreset', () {
    test('accepts exactly expected value count', () {
      final MichelsonInputPreset preset = MichelsonInputPreset(
        id: 'valid',
        values: _buildValues(MichelsonInputPreset.expectedValueCount),
      );

      expect(
        preset.values,
        hasLength(MichelsonInputPreset.expectedValueCount),
      );
    });

    test('throws when value count is less than expected', () {
      expect(
        () => MichelsonInputPreset(
          id: 'too-short',
          values: _buildValues(MichelsonInputPreset.expectedValueCount - 1),
        ),
        throwsA(
          isA<MichelsonInputPresetException>().having(
            (MichelsonInputPresetException error) => error.message,
            'message',
            'Michelson preset must contain exactly '
                '${MichelsonInputPreset.expectedValueCount} values, got '
                '${MichelsonInputPreset.expectedValueCount - 1}.',
          ),
        ),
      );
    });

    test('throws when value count is greater than expected', () {
      expect(
        () => MichelsonInputPreset(
          id: 'too-long',
          values: _buildValues(MichelsonInputPreset.expectedValueCount + 1),
        ),
        throwsA(
          isA<MichelsonInputPresetException>().having(
            (MichelsonInputPresetException error) => error.message,
            'message',
            'Michelson preset must contain exactly '
                '${MichelsonInputPreset.expectedValueCount} values, got '
                '${MichelsonInputPreset.expectedValueCount + 1}.',
          ),
        ),
      );
    });
  });

  test('MichelsonInterferometerViewModel reuses preset expected value count',
      () {
    expect(
      MichelsonInterferometerViewModel.positionCount,
      MichelsonInputPreset.expectedValueCount,
    );
  });
}

List<String> _buildValues(int count) {
  return List<String>.generate(
    count,
    (int index) => index.toString(),
    growable: false,
  );
}
