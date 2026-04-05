import 'dart:math' as math;

import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_angle.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_calibration_result.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_measurement_result.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_wavelength_result.dart';
import 'package:onetj/models/base_model.dart';

class DiffractionGratingViewModel extends BaseViewModel<Never> {
  static const int readingCountPerRow = 4;
  static const int calibrationRowCount = 1;
  static const int wavelengthGroupCount = 2;
  static const int wavelengthRowCount = 2;
  static const List<int> calibrationOrders = <int>[2];
  static const List<int> wavelengthOrders = <int>[1, 2];
  static const double defaultCalibrationReferenceWavelengthNm = 546.07;
  static const double nmToMm = 1e-6;

  static const List<List<String>> defaultCalibrationPreset = <List<String>>[
    <String>['159 03', '339 03', '197 34', '17 34'],
  ];

  static const List<List<List<String>>> defaultWavelengthPresets =
      <List<List<String>>>[
        <List<String>>[
          <String>['171 02', '351 02', '186 06', '6 06'],
          <String>['163 13', '343 13', '193 41', '13 41'],
        ],
        <List<String>>[
          <String>['168 26', '348 26', '188 37', '8 37'],
          <String>['157 52', '337 52', '198 37', '18 37'],
        ],
      ];

  final List<List<String>> _calibrationTexts = List<List<String>>.generate(
    calibrationRowCount,
    (_) => List<String>.filled(readingCountPerRow, '', growable: false),
    growable: false,
  );
  final List<List<List<String>>> _wavelengthTexts =
      List<List<List<String>>>.generate(
        wavelengthGroupCount,
        (_) => List<List<String>>.generate(
          wavelengthRowCount,
          (_) => List<String>.filled(readingCountPerRow, '', growable: false),
          growable: false,
        ),
        growable: false,
      );
  final List<String> _referenceWavelengthTexts = List<String>.filled(
    wavelengthGroupCount,
    '',
    growable: false,
  );

  String _calibrationReferenceText =
      defaultCalibrationReferenceWavelengthNm.toStringAsFixed(2);
  _DiffractionGratingDerivedState? _derivedState;

  List<List<String>> get calibrationTexts => _clone2d(_calibrationTexts);
  List<List<List<String>>> get wavelengthTexts => _clone3d(_wavelengthTexts);
  List<String> get referenceWavelengthTexts =>
      List<String>.unmodifiable(_referenceWavelengthTexts);
  String get calibrationReferenceText => _calibrationReferenceText;

  DiffractionGratingCalibrationResult? get calibrationResult =>
      _getDerivedState().calibrationResult;

  List<List<DiffractionGratingWavelengthRowResult?>> get wavelengthRowResults =>
      _getDerivedState().wavelengthRowResults;

  List<DiffractionGratingWavelengthGroupResult?> get wavelengthResults =>
      _getDerivedState().wavelengthResults;

  void updateCalibrationReading(int rowIndex, int readingIndex, String value) {
    if (!_isValidCalibrationCell(rowIndex, readingIndex)) {
      return;
    }
    if (_calibrationTexts[rowIndex][readingIndex] == value) {
      return;
    }
    _calibrationTexts[rowIndex][readingIndex] = value;
    _invalidateDerivedState();
    notifyListeners();
  }

  void updateWavelengthReading(
    int groupIndex,
    int rowIndex,
    int readingIndex,
    String value,
  ) {
    if (!_isValidWavelengthCell(groupIndex, rowIndex, readingIndex)) {
      return;
    }
    if (_wavelengthTexts[groupIndex][rowIndex][readingIndex] == value) {
      return;
    }
    _wavelengthTexts[groupIndex][rowIndex][readingIndex] = value;
    _invalidateDerivedState();
    notifyListeners();
  }

  void updateCalibrationReferenceText(String value) {
    if (_calibrationReferenceText == value) {
      return;
    }
    _calibrationReferenceText = value;
    _invalidateDerivedState();
    notifyListeners();
  }

  void updateReferenceWavelengthText(int groupIndex, String value) {
    if (groupIndex < 0 || groupIndex >= _referenceWavelengthTexts.length) {
      return;
    }
    if (_referenceWavelengthTexts[groupIndex] == value) {
      return;
    }
    _referenceWavelengthTexts[groupIndex] = value;
    _invalidateDerivedState();
    notifyListeners();
  }

  void applyDefaultPreset() {
    _calibrationReferenceText =
        defaultCalibrationReferenceWavelengthNm.toStringAsFixed(2);
    for (int rowIndex = 0; rowIndex < calibrationRowCount; rowIndex += 1) {
      for (int readingIndex = 0;
          readingIndex < readingCountPerRow;
          readingIndex += 1) {
        _calibrationTexts[rowIndex][readingIndex] =
            defaultCalibrationPreset[rowIndex][readingIndex];
      }
    }
    for (int groupIndex = 0; groupIndex < wavelengthGroupCount; groupIndex += 1) {
      for (int rowIndex = 0; rowIndex < wavelengthRowCount; rowIndex += 1) {
        for (int readingIndex = 0;
            readingIndex < readingCountPerRow;
            readingIndex += 1) {
          _wavelengthTexts[groupIndex][rowIndex][readingIndex] =
              defaultWavelengthPresets[groupIndex][rowIndex][readingIndex];
        }
      }
    }
    _referenceWavelengthTexts[0] = '435.84';
    _referenceWavelengthTexts[1] = '585.94';
    _invalidateDerivedState();
    notifyListeners();
  }

  void clearAll() {
    bool changed = false;
    if (_calibrationReferenceText.isNotEmpty) {
      _calibrationReferenceText = '';
      changed = true;
    }
    for (int rowIndex = 0; rowIndex < calibrationRowCount; rowIndex += 1) {
      for (int readingIndex = 0;
          readingIndex < readingCountPerRow;
          readingIndex += 1) {
        if (_calibrationTexts[rowIndex][readingIndex].isEmpty) {
          continue;
        }
        _calibrationTexts[rowIndex][readingIndex] = '';
        changed = true;
      }
    }
    for (int groupIndex = 0; groupIndex < wavelengthGroupCount; groupIndex += 1) {
      if (_referenceWavelengthTexts[groupIndex].isNotEmpty) {
        _referenceWavelengthTexts[groupIndex] = '';
        changed = true;
      }
      for (int rowIndex = 0; rowIndex < wavelengthRowCount; rowIndex += 1) {
        for (int readingIndex = 0;
            readingIndex < readingCountPerRow;
            readingIndex += 1) {
          if (_wavelengthTexts[groupIndex][rowIndex][readingIndex].isEmpty) {
            continue;
          }
          _wavelengthTexts[groupIndex][rowIndex][readingIndex] = '';
          changed = true;
        }
      }
    }
    if (changed) {
      _invalidateDerivedState();
      notifyListeners();
    }
  }

  _DiffractionGratingDerivedState _getDerivedState() {
    return _derivedState ??= _buildDerivedState();
  }

  void _invalidateDerivedState() {
    _derivedState = null;
  }

  _DiffractionGratingDerivedState _buildDerivedState() {
    final DiffractionGratingCalibrationResult? calibrationResult =
        _buildCalibrationResult();
    final List<double?> referenceWavelengths = List<double?>.generate(
      wavelengthGroupCount,
      _parseReferenceWavelength,
      growable: false,
    );
    final List<List<DiffractionGratingWavelengthRowResult?>> wavelengthRowResults =
        List<List<DiffractionGratingWavelengthRowResult?>>.generate(
          wavelengthGroupCount,
          (int groupIndex) => List<DiffractionGratingWavelengthRowResult?>.generate(
            wavelengthRowCount,
            (int rowIndex) => _buildWavelengthRowResult(
              calibrationResult: calibrationResult,
              referenceNm: referenceWavelengths[groupIndex],
              groupIndex: groupIndex,
              rowIndex: rowIndex,
            ),
            growable: false,
          ),
          growable: false,
        );
    final List<DiffractionGratingWavelengthGroupResult?> wavelengthResults =
        List<DiffractionGratingWavelengthGroupResult?>.generate(
          wavelengthGroupCount,
          (int groupIndex) => _buildWavelengthGroupResult(
            calibrationResult: calibrationResult,
            referenceNm: referenceWavelengths[groupIndex],
            rowResults: wavelengthRowResults[groupIndex],
          ),
          growable: false,
        );
    return _DiffractionGratingDerivedState(
      calibrationResult: calibrationResult,
      wavelengthRowResults: List<List<DiffractionGratingWavelengthRowResult?>>.unmodifiable(
        wavelengthRowResults
            .map(
              (List<DiffractionGratingWavelengthRowResult?> rows) =>
                  List<DiffractionGratingWavelengthRowResult?>.unmodifiable(rows),
            )
            .toList(growable: false),
      ),
      wavelengthResults:
          List<DiffractionGratingWavelengthGroupResult?>.unmodifiable(
            wavelengthResults,
          ),
    );
  }

  DiffractionGratingCalibrationResult? _buildCalibrationResult() {
    final double? referenceNm = double.tryParse(_calibrationReferenceText.trim());
    if (referenceNm == null || referenceNm <= 0) {
      return null;
    }

    final List<DiffractionGratingCalibrationRowResult> rows =
        <DiffractionGratingCalibrationRowResult>[];
    for (int rowIndex = 0; rowIndex < calibrationRowCount; rowIndex += 1) {
      final DiffractionGratingMeasurementResult? measurement =
          _buildMeasurementResult(_calibrationTexts[rowIndex]);
      if (measurement == null || measurement.sinGamma == 0) {
        return null;
      }
      final int order = calibrationOrders[rowIndex];
      final double gratingConstantMm =
          (order * referenceNm * nmToMm) / measurement.sinGamma;
      rows.add(
        DiffractionGratingCalibrationRowResult(
          order: order,
          measurement: measurement,
          gratingConstantMm: gratingConstantMm,
        ),
      );
    }

    final double averageGratingConstantMm = rows.first.gratingConstantMm;
    return DiffractionGratingCalibrationResult(
      referenceWavelengthNm: referenceNm,
      rows: List<DiffractionGratingCalibrationRowResult>.unmodifiable(rows),
      averageGratingConstantMm: averageGratingConstantMm,
    );
  }

  DiffractionGratingWavelengthGroupResult? _buildWavelengthGroupResult({
    required DiffractionGratingCalibrationResult? calibrationResult,
    required double? referenceNm,
    required List<DiffractionGratingWavelengthRowResult?> rowResults,
  }) {
    if (calibrationResult == null || referenceNm == null) {
      return null;
    }
    final List<DiffractionGratingWavelengthRowResult> rows =
        <DiffractionGratingWavelengthRowResult>[];
    for (final DiffractionGratingWavelengthRowResult? rowResult in rowResults) {
      if (rowResult == null) {
        return null;
      }
      rows.add(rowResult);
    }

    final double averageWavelengthNm = rows
            .map((DiffractionGratingWavelengthRowResult row) => row.wavelengthNm)
            .reduce((double a, double b) => a + b) /
        rows.length;
    final double relativeErrorPercent =
        ((averageWavelengthNm - referenceNm).abs() / referenceNm) * 100;
    return DiffractionGratingWavelengthGroupResult(
      averageGratingConstantMm: calibrationResult.averageGratingConstantMm,
      referenceWavelengthNm: referenceNm,
      rows: List<DiffractionGratingWavelengthRowResult>.unmodifiable(rows),
      averageWavelengthNm: averageWavelengthNm,
      relativeErrorPercent: relativeErrorPercent,
    );
  }

  DiffractionGratingWavelengthRowResult? _buildWavelengthRowResult({
    required DiffractionGratingCalibrationResult? calibrationResult,
    required double? referenceNm,
    required int groupIndex,
    required int rowIndex,
  }) {
    if (calibrationResult == null || referenceNm == null) {
      return null;
    }
    final DiffractionGratingMeasurementResult? measurement =
        _buildMeasurementResult(_wavelengthTexts[groupIndex][rowIndex]);
    if (measurement == null) {
      return null;
    }
    final int order = wavelengthOrders[rowIndex];
    final double wavelengthNm =
        (calibrationResult.averageGratingConstantMm / nmToMm) *
        measurement.sinGamma /
        order;
    final double relativeErrorPercent =
        ((wavelengthNm - referenceNm).abs() / referenceNm) * 100;
    return DiffractionGratingWavelengthRowResult(
      order: order,
      measurement: measurement,
      wavelengthNm: wavelengthNm,
      relativeErrorPercent: relativeErrorPercent,
    );
  }

  double? _parseReferenceWavelength(int groupIndex) {
    final double? referenceNm =
        double.tryParse(_referenceWavelengthTexts[groupIndex].trim());
    if (referenceNm == null || referenceNm <= 0) {
      return null;
    }
    return referenceNm;
  }

  DiffractionGratingMeasurementResult? _buildMeasurementResult(
    List<String> texts,
  ) {
    final List<double> readings = <double>[];
    for (final String text in texts) {
      final DiffractionGratingAngle? angle =
          DiffractionGratingAngle.tryParse(text);
      if (angle == null) {
        return null;
      }
      readings.add(angle.degrees);
    }

    final double firstDifferenceDegrees =
        DiffractionGratingAngle.circularDifferenceDegrees(
      readings[2],
      readings[0],
    );
    final double secondDifferenceDegrees =
        DiffractionGratingAngle.circularDifferenceDegrees(
      readings[3],
      readings[1],
    );
    final double gammaDegrees =
        (firstDifferenceDegrees + secondDifferenceDegrees) / 4;
    final double sinGamma = math.sin(gammaDegrees * math.pi / 180);
    return DiffractionGratingMeasurementResult(
      readingsDegrees: List<double>.unmodifiable(readings),
      firstDifferenceDegrees: firstDifferenceDegrees,
      secondDifferenceDegrees: secondDifferenceDegrees,
      gammaDegrees: gammaDegrees,
      sinGamma: sinGamma,
    );
  }

  bool _isValidCalibrationCell(int rowIndex, int readingIndex) {
    return rowIndex >= 0 &&
        rowIndex < _calibrationTexts.length &&
        readingIndex >= 0 &&
        readingIndex < readingCountPerRow;
  }

  bool _isValidWavelengthCell(
    int groupIndex,
    int rowIndex,
    int readingIndex,
  ) {
    return groupIndex >= 0 &&
        groupIndex < _wavelengthTexts.length &&
        rowIndex >= 0 &&
        rowIndex < wavelengthRowCount &&
        readingIndex >= 0 &&
        readingIndex < readingCountPerRow;
  }

  List<List<String>> _clone2d(List<List<String>> source) {
    return List<List<String>>.unmodifiable(
      source
          .map(
            (List<String> row) => List<String>.unmodifiable(row),
          )
          .toList(growable: false),
    );
  }

  List<List<List<String>>> _clone3d(List<List<List<String>>> source) {
    return List<List<List<String>>>.unmodifiable(
      source
          .map(
            (List<List<String>> group) => List<List<String>>.unmodifiable(
              group
                  .map(
                    (List<String> row) => List<String>.unmodifiable(row),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DiffractionGratingDerivedState {
  const _DiffractionGratingDerivedState({
    required this.calibrationResult,
    required this.wavelengthRowResults,
    required this.wavelengthResults,
  });

  final DiffractionGratingCalibrationResult? calibrationResult;
  final List<List<DiffractionGratingWavelengthRowResult?>> wavelengthRowResults;
  final List<DiffractionGratingWavelengthGroupResult?> wavelengthResults;
}
