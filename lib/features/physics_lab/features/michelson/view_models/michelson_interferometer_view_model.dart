import 'package:onetj/features/physics_lab/features/michelson/models/michelson_measurement_result.dart';
import 'package:onetj/models/base_model.dart';

class MichelsonInterferometerViewModel extends BaseViewModel<Never> {
  static const int positionCount = 10;
  static const int differenceOffset = 5;
  static const double referenceValue = 623.8;
  static const double fringesPerStep = 75;
  static const double mmToNm = 1000000;

  final List<String> _positionTexts = List<String>.filled(
    positionCount,
    '',
    growable: false,
  );

  List<String> get positionTexts => List<String>.unmodifiable(_positionTexts);

  MichelsonMeasurementResult? get result => _buildResult();

  bool get hasCompleteInput => result != null;

  void updatePositionText(int index, String value) {
    if (index < 0 || index >= _positionTexts.length) {
      return;
    }
    if (_positionTexts[index] == value) {
      return;
    }
    _positionTexts[index] = value;
    notifyListeners();
  }

  void clearAll() {
    bool changed = false;
    for (int index = 0; index < _positionTexts.length; index += 1) {
      if (_positionTexts[index].isEmpty) {
        continue;
      }
      _positionTexts[index] = '';
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  MichelsonMeasurementResult? _buildResult() {
    final List<double> positions = <double>[];
    for (final String text in _positionTexts) {
      final String trimmed = text.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final double? value = double.tryParse(trimmed);
      if (value == null) {
        return null;
      }
      positions.add(value);
    }

    final List<double> differencesMm = <double>[];
    for (int index = 0; index < differenceOffset; index += 1) {
      differencesMm.add(positions[index + differenceOffset] - positions[index]);
    }
    final List<double> wavelengthsNm = differencesMm
        .map((differenceMm) => (differenceMm / fringesPerStep) * mmToNm)
        .toList(growable: false);
    final double averageWavelengthNm =
        wavelengthsNm.reduce((a, b) => a + b) / wavelengthsNm.length;
    final double relativeErrorPercent =
        ((averageWavelengthNm - referenceValue).abs() / referenceValue) * 100;
    return MichelsonMeasurementResult(
      positions: List<double>.unmodifiable(positions),
      differencesMm: List<double>.unmodifiable(differencesMm),
      wavelengthsNm: List<double>.unmodifiable(wavelengthsNm),
      averageWavelengthNm: averageWavelengthNm,
      relativeErrorPercent: relativeErrorPercent,
    );
  }
}
