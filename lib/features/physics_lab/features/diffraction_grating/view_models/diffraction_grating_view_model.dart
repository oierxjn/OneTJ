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

  List<List<String>> get calibrationTexts => _clone2d(_calibrationTexts);
  List<List<List<String>>> get wavelengthTexts => _clone3d(_wavelengthTexts);
  List<String> get referenceWavelengthTexts =>
      List<String>.unmodifiable(_referenceWavelengthTexts);
  String get calibrationReferenceText => _calibrationReferenceText;

  DiffractionGratingCalibrationResult? get calibrationResult =>
      _buildCalibrationResult();

  List<List<DiffractionGratingWavelengthRowResult?>> get wavelengthRowResults =>
      List<List<DiffractionGratingWavelengthRowResult?>>.generate(
        wavelengthGroupCount,
        (int groupIndex) => List<DiffractionGratingWavelengthRowResult?>.generate(
          wavelengthRowCount,
          (int rowIndex) => _buildWavelengthRowResult(groupIndex, rowIndex),
          growable: false,
        ),
        growable: false,
      );

  List<DiffractionGratingWavelengthGroupResult?> get wavelengthResults =>
      List<DiffractionGratingWavelengthGroupResult?>.generate(
        wavelengthGroupCount,
        _buildWavelengthGroupResult,
        growable: false,
      );

  void updateCalibrationReading(int rowIndex, int readingIndex, String value) {
    if (!_isValidCalibrationCell(rowIndex, readingIndex)) {
      return;
    }
    if (_calibrationTexts[rowIndex][readingIndex] == value) {
      return;
    }
    _calibrationTexts[rowIndex][readingIndex] = value;
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
    notifyListeners();
  }

  void updateCalibrationReferenceText(String value) {
    if (_calibrationReferenceText == value) {
      return;
    }
    _calibrationReferenceText = value;
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
      notifyListeners();
    }
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

  DiffractionGratingWavelengthGroupResult? _buildWavelengthGroupResult(
    int groupIndex,
  ) {
    final DiffractionGratingCalibrationResult? calibration = calibrationResult;
    if (calibration == null) {
      return null;
    }
    final double? referenceNm = _parseReferenceWavelength(groupIndex);
    if (referenceNm == null) {
      return null;
    }

    final List<DiffractionGratingWavelengthRowResult> rows =
        <DiffractionGratingWavelengthRowResult>[];
    for (int rowIndex = 0; rowIndex < wavelengthRowCount; rowIndex += 1) {
      final DiffractionGratingWavelengthRowResult? rowResult =
          _buildWavelengthRowResult(groupIndex, rowIndex);
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
      averageGratingConstantMm: calibration.averageGratingConstantMm,
      referenceWavelengthNm: referenceNm,
      rows: List<DiffractionGratingWavelengthRowResult>.unmodifiable(rows),
      averageWavelengthNm: averageWavelengthNm,
      relativeErrorPercent: relativeErrorPercent,
    );
  }

  DiffractionGratingWavelengthRowResult? _buildWavelengthRowResult(
    int groupIndex,
    int rowIndex,
  ) {
    final DiffractionGratingCalibrationResult? calibration = calibrationResult;
    if (calibration == null) {
      return null;
    }
    final double? referenceNm = _parseReferenceWavelength(groupIndex);
    if (referenceNm == null) {
      return null;
    }
    final DiffractionGratingMeasurementResult? measurement =
        _buildMeasurementResult(_wavelengthTexts[groupIndex][rowIndex]);
    if (measurement == null) {
      return null;
    }
    final int order = wavelengthOrders[rowIndex];
    final double wavelengthNm =
        (calibration.averageGratingConstantMm / nmToMm) *
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
