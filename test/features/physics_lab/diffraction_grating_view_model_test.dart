import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_calibration_result.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_wavelength_result.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/view_models/diffraction_grating_view_model.dart';

void main() {
  group('DiffractionGratingViewModel', () {
    test('builds calibration and wavelength results from valid inputs', () {
      final DiffractionGratingViewModel viewModel = DiffractionGratingViewModel();

      viewModel.updateCalibrationReferenceText('546.07');
      _fillRow(viewModel.updateCalibrationReading, 0, <String>[
        '159 03',
        '339 03',
        '197 34',
        '17 34',
      ]);
      viewModel.updateReferenceWavelengthText(0, '435.84');
      _fillGroupRow(viewModel, 0, 0, <String>[
        '171 02',
        '351 02',
        '186 06',
        '6 06',
      ]);
      _fillGroupRow(viewModel, 0, 1, <String>[
        '163 13',
        '343 13',
        '193 41',
        '13 41',
      ]);
      viewModel.updateReferenceWavelengthText(1, '585.94');
      _fillGroupRow(viewModel, 1, 0, <String>[
        '168 26',
        '348 26',
        '188 37',
        '8 37',
      ]);
      _fillGroupRow(viewModel, 1, 1, <String>[
        '157 52',
        '337 52',
        '198 37',
        '18 37',
      ]);

      final DiffractionGratingCalibrationResult? calibration =
          viewModel.calibrationResult;
      final List<List<DiffractionGratingWavelengthRowResult?>>
          wavelengthRowResults = viewModel.wavelengthRowResults;
      final List<DiffractionGratingWavelengthGroupResult?> wavelengthResults =
          viewModel.wavelengthResults;

      expect(calibration, isNotNull);
      expect(calibration!.rows, hasLength(1));
      expect(
        calibration.rows.first.measurement.firstDifferenceDegrees,
        closeTo(38.5166666667, 1e-9),
      );
      expect(
        calibration.averageGratingConstantMm,
        closeTo(0.0033112414727, 1e-12),
      );

      expect(wavelengthResults[0], isNotNull);
      expect(
        wavelengthResults[0]!.rows.first.wavelengthNm,
        closeTo(434.1135892658, 1e-9),
      );
      expect(
        wavelengthResults[0]!.averageWavelengthNm,
        closeTo(434.5644308533, 1e-9),
      );
      expect(
        wavelengthResults[0]!.relativeErrorPercent,
        closeTo(0.2926691324, 1e-9),
      );
      expect(
        wavelengthRowResults[0].first!.wavelengthNm,
        closeTo(wavelengthResults[0]!.rows.first.wavelengthNm, 1e-9),
      );
      expect(
        wavelengthRowResults[0][1]!.wavelengthNm,
        closeTo(wavelengthResults[0]!.rows[1].wavelengthNm, 1e-9),
      );

      expect(wavelengthResults[1], isNotNull);
      expect(
        wavelengthResults[1]!.averageWavelengthNm,
        closeTo(578.3166972080, 1e-9),
      );
      expect(
        wavelengthResults[1]!.relativeErrorPercent,
        closeTo(1.3010381254, 1e-9),
      );
      expect(
        wavelengthRowResults[1].first!.wavelengthNm,
        closeTo(wavelengthResults[1]!.rows.first.wavelengthNm, 1e-9),
      );
      expect(
        wavelengthRowResults[1][1]!.wavelengthNm,
        closeTo(wavelengthResults[1]!.rows[1].wavelengthNm, 1e-9),
      );

      viewModel.dispose();
    });

    test('returns null wavelength groups when calibration is incomplete', () {
      final DiffractionGratingViewModel viewModel = DiffractionGratingViewModel();

      viewModel.updateReferenceWavelengthText(0, '435.84');
      _fillGroupRow(viewModel, 0, 0, <String>[
        '171 02',
        '351 02',
        '186 06',
        '6 06',
      ]);
      _fillGroupRow(viewModel, 0, 1, <String>[
        '163 13',
        '343 13',
        '193 41',
        '13 41',
      ]);

      expect(viewModel.calibrationResult, isNull);
      expect(viewModel.wavelengthResults.first, isNull);

      viewModel.dispose();
    });

    test('returns expected results for default preset', () {
      final DiffractionGratingViewModel viewModel = DiffractionGratingViewModel();

      viewModel.applyDefaultPreset();

      final DiffractionGratingCalibrationResult? calibration =
          viewModel.calibrationResult;
      final List<DiffractionGratingWavelengthGroupResult?> wavelengthResults =
          viewModel.wavelengthResults;

      expect(calibration, isNotNull);
      expect(
        calibration!.averageGratingConstantMm,
        closeTo(0.0033112414727, 1e-12),
      );
      expect(wavelengthResults, hasLength(2));
      expect(wavelengthResults[0], isNotNull);
      expect(
        wavelengthResults[0]!.averageWavelengthNm,
        closeTo(434.5644308533, 1e-9),
      );
      expect(
        wavelengthResults[0]!.relativeErrorPercent,
        closeTo(0.2926691324, 1e-9),
      );
      expect(wavelengthResults[1], isNotNull);
      expect(
        wavelengthResults[1]!.averageWavelengthNm,
        closeTo(578.3166972080, 1e-9),
      );
      expect(
        wavelengthResults[1]!.relativeErrorPercent,
        closeTo(1.3010381254, 1e-9),
      );

      viewModel.dispose();
    });

    test('clearAll resets all text state', () {
      final DiffractionGratingViewModel viewModel = DiffractionGratingViewModel();

      viewModel.applyDefaultPreset();
      expect(viewModel.calibrationResult, isNotNull);

      viewModel.clearAll();

      expect(viewModel.calibrationReferenceText, isEmpty);
      expect(viewModel.referenceWavelengthTexts, orderedEquals(<String>['', '']));
      expect(viewModel.calibrationResult, isNull);
      expect(viewModel.wavelengthResults, orderedEquals(<Null>[null, null]));

      viewModel.dispose();
    });
  });
}

void _fillRow(
  void Function(int rowIndex, int readingIndex, String value) update,
  int rowIndex,
  List<String> values,
) {
  for (int readingIndex = 0; readingIndex < values.length; readingIndex += 1) {
    update(rowIndex, readingIndex, values[readingIndex]);
  }
}

void _fillGroupRow(
  DiffractionGratingViewModel viewModel,
  int groupIndex,
  int rowIndex,
  List<String> values,
) {
  for (int readingIndex = 0; readingIndex < values.length; readingIndex += 1) {
    viewModel.updateWavelengthReading(
      groupIndex,
      rowIndex,
      readingIndex,
      values[readingIndex],
    );
  }
}
