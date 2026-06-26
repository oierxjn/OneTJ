import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/view_models/franck_hertz_view_model.dart';

void main() {
  group('FranckHertzViewModel', () {
    test('starts with 50 empty rows and no input', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();

      expect(viewModel.rows, hasLength(FranckHertzViewModel.defaultRowCount));
      expect(viewModel.rows.first.index, 1);
      expect(
        viewModel.rows.last.index,
        FranckHertzViewModel.defaultRowCount,
      );
      expect(viewModel.metadata.vfText, isEmpty);
      expect(viewModel.metadata.vg1kText, isEmpty);
      expect(viewModel.metadata.vg2aText, isEmpty);
      expect(
        viewModel.referenceVoltageText,
        FranckHertzViewModel.defaultReferenceVoltageText,
      );
      expect(viewModel.analysisResult.validPoints, isEmpty);
      expect(viewModel.hasAnyInput, isFalse);

      viewModel.dispose();
    });

    test('updates metadata fields', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();

      viewModel.updateVfText('2.5');
      viewModel.updateVg1kText('1.5');
      viewModel.updateVg2aText('7.0');

      expect(viewModel.metadata.vfText, '2.5');
      expect(viewModel.metadata.vg1kText, '1.5');
      expect(viewModel.metadata.vg2aText, '7.0');
      expect(viewModel.hasAnyInput, isTrue);

      viewModel.dispose();
    });

    test('updates row values', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();

      viewModel.updateRowVg2kText(0, '12.0');
      viewModel.updateRowIpText(0, '0.32');

      expect(viewModel.rows.first.vg2kText, '12.0');
      expect(viewModel.rows.first.ipText, '0.32');
      expect(viewModel.hasAnyInput, isTrue);

      viewModel.dispose();
    });

    test('adds and removes rows while keeping indices stable', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();

      viewModel.addRow();
      expect(viewModel.rows, hasLength(51));
      expect(viewModel.rows.last.index, 51);

      viewModel.removeRow(1);
      expect(viewModel.rows, hasLength(50));
      expect(viewModel.rows[1].index, 2);
      expect(viewModel.rows.last.index, 50);

      viewModel.dispose();
    });

    test('clearAll resets metadata, row values, and row count', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();

      viewModel.updateVfText('2.4');
      viewModel.updateReferenceVoltageText('10.00');
      viewModel.updateRowVg2kText(0, '11');
      viewModel.updateRowIpText(0, '0.12');
      viewModel.addRow();

      viewModel.clearAll();

      expect(viewModel.metadata.vfText, isEmpty);
      expect(viewModel.metadata.vg1kText, isEmpty);
      expect(viewModel.metadata.vg2aText, isEmpty);
      expect(
        viewModel.referenceVoltageText,
        FranckHertzViewModel.defaultReferenceVoltageText,
      );
      expect(viewModel.rows, hasLength(FranckHertzViewModel.defaultRowCount));
      expect(viewModel.rows.every((row) => row.vg2kText.isEmpty), isTrue);
      expect(viewModel.rows.every((row) => row.ipText.isEmpty), isTrue);
      expect(viewModel.hasAnyInput, isFalse);

      viewModel.dispose();
    });

    test('builds analysis result from valid points and sorts by voltage', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();
      const List<double> voltages = <double>[
        20,
        19,
        18,
        17,
        16,
        15,
        14,
        13,
        12,
        11,
        10,
      ];
      const List<double> currents = <double>[
        1,
        3,
        1,
        3,
        1,
        3,
        1,
        3,
        1,
        3,
        1,
      ];

      for (int index = 0; index < voltages.length; index += 1) {
        viewModel.updateRowVg2kText(index, voltages[index].toStringAsFixed(0));
        viewModel.updateRowIpText(index, currents[index].toStringAsFixed(0));
      }

      final analysisResult = viewModel.analysisResult;
      expect(analysisResult.validPoints.first.voltage, 10);
      expect(analysisResult.validPoints.last.voltage, 20);
      expect(analysisResult.smoothedPoints, hasLength(7));
      expect(analysisResult.peakResult, isNotNull);
      expect(analysisResult.valleyResult, isNotNull);
      expect(
        analysisResult.peakResult!.intervals,
        orderedEquals(const <double>[2, 2]),
      );
      expect(
        analysisResult.valleyResult!.intervals,
        orderedEquals(const <double>[2]),
      );
      expect(analysisResult.peakResult!.averageInterval, 2);
      expect(analysisResult.valleyResult!.averageInterval, 2);
      expect(analysisResult.finalExcitationPotential, 2);
      expect(
        analysisResult.relativeErrorPercent,
        closeTo(82.77347114556417, 1e-9),
      );

      viewModel.dispose();
    });

    test('updates relative error when reference voltage changes', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();
      const List<double> currents = <double>[
        1,
        3,
        1,
        3,
        1,
        3,
        1,
        3,
        1,
        3,
        1,
      ];

      for (int index = 0; index < currents.length; index += 1) {
        viewModel.updateRowVg2kText(index, (10 + index).toString());
        viewModel.updateRowIpText(index, currents[index].toStringAsFixed(0));
      }

      viewModel.updateReferenceVoltageText('2.00');

      final analysisResult = viewModel.analysisResult;
      expect(analysisResult.referenceVoltage, 2);
      expect(analysisResult.finalExcitationPotential, 2);
      expect(analysisResult.relativeErrorPercent, 0);

      viewModel.dispose();
    });

    test('returns partial result when there are not enough extrema', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();
      const List<double> currents = <double>[1, 2, 3, 4, 5, 6, 7];

      for (int index = 0; index < currents.length; index += 1) {
        viewModel.updateRowVg2kText(index, index.toString());
        viewModel.updateRowIpText(index, currents[index].toStringAsFixed(0));
      }

      final analysisResult = viewModel.analysisResult;
      expect(analysisResult.smoothedPoints, hasLength(3));
      expect(analysisResult.peakResult, isNull);
      expect(analysisResult.valleyResult, isNull);
      expect(analysisResult.finalExcitationPotential, isNull);
      expect(analysisResult.relativeErrorPercent, isNull);

      viewModel.dispose();
    });

    test('applyPreset expands rows, fills preset values, and keeps reference', () {
      final FranckHertzViewModel viewModel = FranckHertzViewModel();

      viewModel.updateVfText('2.5');
      viewModel.updateReferenceVoltageText('12.34');
      viewModel.updateRowVg2kText(49, '999');
      viewModel.updateRowIpText(49, '999');

      viewModel.applyPreset();

      expect(viewModel.metadata.vfText, '2.5');
      expect(viewModel.referenceVoltageText, '12.34');
      expect(viewModel.rows, hasLength(FranckHertzViewModel.presetRows.length));
      expect(viewModel.rows.first.vg2kText, '0');
      expect(viewModel.rows.first.ipText, '0');
      expect(viewModel.rows[1].vg2kText, '0.5');
      expect(viewModel.rows[1].ipText, '0');
      expect(viewModel.rows.last.vg2kText, '82');
      expect(viewModel.rows.last.ipText, '2.777');
      expect(viewModel.analysisResult.validPoints.length, viewModel.rows.length);

      viewModel.dispose();
    });
  });
}
