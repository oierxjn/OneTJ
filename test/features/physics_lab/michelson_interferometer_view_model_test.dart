import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/michelson/models/michelson_input_preset.dart';
import 'package:onetj/features/physics_lab/features/michelson/models/michelson_measurement_result.dart';
import 'package:onetj/features/physics_lab/features/michelson/view_models/michelson_interferometer_view_model.dart';

void main() {
  group('MichelsonInterferometerViewModel.result', () {
    test('returns expected result for default preset', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();

      viewModel.applyPreset(MichelsonInterferometerViewModel.defaultPreset);

      expect(
        viewModel.positionTexts,
        MichelsonInterferometerViewModel.defaultPreset.values,
      );
      expect(viewModel.hasCompleteInput, isTrue);

      final MichelsonMeasurementResult? result = viewModel.result;

      expect(result, isNotNull);
      expect(
        result!.positions,
        orderedEquals(<double>[
          50.41310,
          50.42285,
          50.43227,
          50.44175,
          50.45140,
          50.46085,
          50.47045,
          50.47997,
          50.48950,
          50.49908,
        ]),
      );
      expect(result.differencesMm[0], closeTo(0.04775, 1e-9));
      expect(result.differencesMm[1], closeTo(0.04760, 1e-9));
      expect(result.differencesMm[2], closeTo(0.04770, 1e-9));
      expect(result.differencesMm[3], closeTo(0.04775, 1e-9));
      expect(result.differencesMm[4], closeTo(0.04768, 1e-9));
      expect(result.averageDifferenceMm, closeTo(0.047696, 1e-9));
      expect(result.wavelengthNm, closeTo(635.9466666667, 1e-9));
      expect(result.relativeErrorPercent, closeTo(1.9472053008, 1e-9));

      viewModel.dispose();
    });

    test('calculates result for valid manual inputs', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();
      final List<String> values = <String>[
        '1.0',
        '2.0',
        '3.0',
        '4.0',
        '5.0',
        '6.5',
        '7.5',
        '8.5',
        '9.5',
        '10.5',
      ];

      for (int index = 0; index < values.length; index += 1) {
        viewModel.updatePositionText(index, values[index]);
      }

      final MichelsonMeasurementResult? result = viewModel.result;

      expect(viewModel.hasCompleteInput, isTrue);
      expect(result, isNotNull);
      expect(
        result!.positions,
        orderedEquals(<double>[
          1.0,
          2.0,
          3.0,
          4.0,
          5.0,
          6.5,
          7.5,
          8.5,
          9.5,
          10.5,
        ]),
      );
      expect(
        result.differencesMm,
        orderedEquals(<Matcher>[
          closeTo(5.5, 1e-9),
          closeTo(5.5, 1e-9),
          closeTo(5.5, 1e-9),
          closeTo(5.5, 1e-9),
          closeTo(5.5, 1e-9),
        ]),
      );
      expect(result.averageDifferenceMm, closeTo(5.5, 1e-9));
      expect(result.wavelengthNm, closeTo(73333.3333333333, 1e-6));
      expect(result.relativeErrorPercent, closeTo(11654.7809165298, 1e-6));

      viewModel.dispose();
    });

    test('returns null when inputs are incomplete', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();

      for (int index = 0; index < 5; index += 1) {
        viewModel.updatePositionText(index, '${index + 1}.0');
      }

      expect(viewModel.result, isNull);
      expect(viewModel.hasCompleteInput, isFalse);

      viewModel.dispose();
    });

    test('returns null when any input is blank after trimming', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();

      for (int index = 0; index < MichelsonInterferometerViewModel.positionCount;
          index += 1) {
        viewModel.updatePositionText(index, '${index + 1}.0');
      }
      viewModel.updatePositionText(3, '   ');

      expect(viewModel.result, isNull);
      expect(viewModel.hasCompleteInput, isFalse);

      viewModel.dispose();
    });

    test('returns null when any input is invalid', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();

      for (int index = 0; index < MichelsonInterferometerViewModel.positionCount;
          index += 1) {
        viewModel.updatePositionText(index, '${index + 1}.0');
      }
      viewModel.updatePositionText(6, 'abc');

      expect(viewModel.result, isNull);
      expect(viewModel.hasCompleteInput, isFalse);

      viewModel.dispose();
    });
  });

  group('MichelsonInterferometerViewModel state changes', () {
    test('applyPreset replaces existing values', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();
      final MichelsonInputPreset preset = MichelsonInputPreset(
        id: 'custom',
        values: <String>[
          '10',
          '11',
          '12',
          '13',
          '14',
          '15',
          '16',
          '17',
          '18',
          '19',
        ],
      );

      for (int index = 0; index < MichelsonInterferometerViewModel.positionCount;
          index += 1) {
        viewModel.updatePositionText(index, '${index}');
      }

      viewModel.applyPreset(preset);

      expect(viewModel.positionTexts, orderedEquals(preset.values));
      expect(viewModel.hasCompleteInput, isTrue);

      viewModel.dispose();
    });

    test('clearAll resets positions and result', () {
      final MichelsonInterferometerViewModel viewModel =
          MichelsonInterferometerViewModel();

      viewModel.applyPreset(MichelsonInterferometerViewModel.defaultPreset);
      expect(viewModel.result, isNotNull);

      viewModel.clearAll();

      expect(
        viewModel.positionTexts,
        orderedEquals(
          List<String>.filled(
            MichelsonInterferometerViewModel.positionCount,
            '',
          ),
        ),
      );
      expect(viewModel.result, isNull);
      expect(viewModel.hasCompleteInput, isFalse);

      viewModel.dispose();
    });
  });
}
