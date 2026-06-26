import 'package:onetj/features/physics_lab/features/franck_hertz/models/franck_hertz_analysis_result.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/models/franck_hertz_measurement_row.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/models/franck_hertz_metadata.dart';
import 'package:onetj/models/base_model.dart';

class FranckHertzViewModel extends BaseViewModel<Never> {
  static const int defaultRowCount = 50;
  static const String defaultReferenceVoltageText = '11.61';
  static const List<List<String>> presetRows = <List<String>>[
    <String>['0', '0'],
    <String>['0.5', '0'],
    <String>['1', '0'],
    <String>['1.5', '0'],
    <String>['2', '0'],
    <String>['2.5', '0'],
    <String>['3', '0'],
    <String>['3.5', '0'],
    <String>['4', '0'],
    <String>['4.5', '0'],
    <String>['5', '0'],
    <String>['5.5', '0'],
    <String>['6', '0'],
    <String>['6.5', '0'],
    <String>['7', '0'],
    <String>['7.5', '0'],
    <String>['8', '0'],
    <String>['8.5', '0'],
    <String>['9', '0'],
    <String>['9.5', '0.002'],
    <String>['10', '0.018'],
    <String>['10.5', '0.05'],
    <String>['11', '0.089'],
    <String>['11.5', '0.125'],
    <String>['12', '0.159'],
    <String>['12.5', '0.187'],
    <String>['13', '0.162'],
    <String>['13.5', '0.186'],
    <String>['14', '0.199'],
    <String>['14.5', '0.218'],
    <String>['15', '0.221'],
    <String>['15.5', '0.242'],
    <String>['16', '0.233'],
    <String>['16.5', '0.241'],
    <String>['17', '0.258'],
    <String>['17.5', '0.268'],
    <String>['18', '0.276'],
    <String>['18.5', '0.289'],
    <String>['19', '0.301'],
    <String>['19.5', '0.293'],
    <String>['20', '0.294'],
    <String>['20.5', '0.303'],
    <String>['21', '0.312'],
    <String>['21.5', '0.321'],
    <String>['22', '0.326'],
    <String>['22.5', '0.332'],
    <String>['23', '0.343'],
    <String>['23.5', '0.348'],
    <String>['24', '0.351'],
    <String>['24.5', '0.375'],
    <String>['25', '0.411'],
    <String>['25.5', '0.434'],
    <String>['26', '0.482'],
    <String>['26.5', '0.527'],
    <String>['27', '0.586'],
    <String>['27.5', '0.695'],
    <String>['28', '0.765'],
    <String>['28.5', '0.837'],
    <String>['29', '0.909'],
    <String>['29.5', '0.975'],
    <String>['30', '1.033'],
    <String>['30.5', '1.082'],
    <String>['31', '1.121'],
    <String>['31.5', '1.146'],
    <String>['32', '1.16'],
    <String>['32.5', '1.153'],
    <String>['33', '1.135'],
    <String>['33.5', '1.112'],
    <String>['34', '1.057'],
    <String>['34.5', '1.039'],
    <String>['35', '0.959'],
    <String>['35.5', '0.91'],
    <String>['36', '0.89'],
    <String>['36.5', '0.927'],
    <String>['37', '1.23'],
    <String>['37.5', '1.369'],
    <String>['38', '1.525'],
    <String>['38.5', '1.688'],
    <String>['39', '1.798'],
    <String>['39.5', '1.964'],
    <String>['40', '2.111'],
    <String>['40.5', '2.23'],
    <String>['41', '2.316'],
    <String>['41.5', '2.363'],
    <String>['42', '2.384'],
    <String>['42.5', '2.366'],
    <String>['43', '2.309'],
    <String>['43.5', '2.213'],
    <String>['44', '2.076'],
    <String>['44.5', '1.903'],
    <String>['45', '1.713'],
    <String>['45.5', '1.489'],
    <String>['46', '1.361'],
    <String>['46.5', '1.268'],
    <String>['47', '1.304'],
    <String>['47.5', '1.45'],
    <String>['48', '1.671'],
    <String>['48.5', '1.927'],
    <String>['49', '2.179'],
    <String>['49.5', '2.44'],
    <String>['50', '2.62'],
    <String>['50.5', '2.856'],
    <String>['51', '3.05'],
    <String>['51.5', '3.205'],
    <String>['52', '3.274'],
    <String>['52.5', '3.38'],
    <String>['53', '3.422'],
    <String>['53.5', '3.402'],
    <String>['54', '3.321'],
    <String>['54.5', '3.179'],
    <String>['55', '2.974'],
    <String>['55.5', '2.710'],
    <String>['56', '2.399'],
    <String>['56.5', '2.065'],
    <String>['57', '1.742'],
    <String>['57.5', '1.507'],
    <String>['58', '1.454'],
    <String>['58.5', '1.795'],
    <String>['59', '2.026'],
    <String>['59.5', '2.321'],
    <String>['60', '2.635'],
    <String>['60.5', '2.86'],
    <String>['61', '3.195'],
    <String>['61.5', '3.509'],
    <String>['62', '3.774'],
    <String>['62.5', '4.007'],
    <String>['63', '4.174'],
    <String>['63.5', '4.294'],
    <String>['64', '4.346'],
    <String>['64.5', '4.349'],
    <String>['65', '4.317'],
    <String>['65.5', '4.208'],
    <String>['66', '4.023'],
    <String>['66.5', '3.77'],
    <String>['67', '3.451'],
    <String>['67.5', '3.074'],
    <String>['68', '2.687'],
    <String>['68.5', '2.305'],
    <String>['69', '2.02'],
    <String>['69.5', '1.911'],
    <String>['70', '1.995'],
    <String>['70.5', '2.232'],
    <String>['71', '2.548'],
    <String>['71.5', '2.896'],
    <String>['72', '3.257'],
    <String>['72.5', '3.611'],
    <String>['73', '3.951'],
    <String>['73.5', '4.194'],
    <String>['74', '4.509'],
    <String>['74.5', '4.755'],
    <String>['75', '4.945'],
    <String>['75.5', '5.071'],
    <String>['76', '5.133'],
    <String>['76.5', '5.128'],
    <String>['77', '5.052'],
    <String>['77.5', '4.905'],
    <String>['78', '4.69'],
    <String>['78.5', '4.407'],
    <String>['79', '4.067'],
    <String>['79.5', '3.685'],
    <String>['80', '3.287'],
    <String>['80.5', '2.948'],
    <String>['81', '2.74'],
    <String>['81.5', '2.641'],
    <String>['82', '2.777'],
  ];

  String _vfText = '';
  String _vg1kText = '';
  String _vg2aText = '';
  String _referenceVoltageText = defaultReferenceVoltageText;
  final List<FranckHertzMeasurementRow> _rows =
      List<FranckHertzMeasurementRow>.generate(
    defaultRowCount,
    (int index) => FranckHertzMeasurementRow(
      index: index + 1,
      vg2kText: '',
      ipText: '',
    ),
  );

  FranckHertzMetadata get metadata => FranckHertzMetadata(
        vfText: _vfText,
        vg1kText: _vg1kText,
        vg2aText: _vg2aText,
      );
  String get referenceVoltageText => _referenceVoltageText;

  List<FranckHertzMeasurementRow> get rows =>
      List<FranckHertzMeasurementRow>.unmodifiable(_rows);
  FranckHertzAnalysisResult get analysisResult => _buildAnalysisResult();

  bool get hasAnyInput {
    if (metadata.hasAnyInput) {
      return true;
    }
    return _rows.any((FranckHertzMeasurementRow row) => row.hasAnyInput);
  }

  void updateVfText(String value) {
    if (_vfText == value) {
      return;
    }
    _vfText = value;
    notifyListeners();
  }

  void updateVg1kText(String value) {
    if (_vg1kText == value) {
      return;
    }
    _vg1kText = value;
    notifyListeners();
  }

  void updateVg2aText(String value) {
    if (_vg2aText == value) {
      return;
    }
    _vg2aText = value;
    notifyListeners();
  }

  void updateReferenceVoltageText(String value) {
    if (_referenceVoltageText == value) {
      return;
    }
    _referenceVoltageText = value;
    notifyListeners();
  }

  void updateRowVg2kText(int rowIndex, String value) {
    if (!_isValidRowIndex(rowIndex)) {
      return;
    }
    final FranckHertzMeasurementRow row = _rows[rowIndex];
    if (row.vg2kText == value) {
      return;
    }
    _rows[rowIndex] = row.copyWith(vg2kText: value);
    notifyListeners();
  }

  void updateRowIpText(int rowIndex, String value) {
    if (!_isValidRowIndex(rowIndex)) {
      return;
    }
    final FranckHertzMeasurementRow row = _rows[rowIndex];
    if (row.ipText == value) {
      return;
    }
    _rows[rowIndex] = row.copyWith(ipText: value);
    notifyListeners();
  }

  void addRow() {
    _rows.add(
      FranckHertzMeasurementRow(
        index: _rows.length + 1,
        vg2kText: '',
        ipText: '',
      ),
    );
    notifyListeners();
  }

  void removeRow(int rowIndex) {
    if (!_isValidRowIndex(rowIndex)) {
      return;
    }
    _rows.removeAt(rowIndex);
    for (int index = rowIndex; index < _rows.length; index += 1) {
      final FranckHertzMeasurementRow row = _rows[index];
      _rows[index] = row.copyWith(index: index + 1);
    }
    notifyListeners();
  }

  void applyPreset() {
    while (_rows.length < presetRows.length) {
      _rows.add(
        FranckHertzMeasurementRow(
          index: _rows.length + 1,
          vg2kText: '',
          ipText: '',
        ),
      );
    }
    for (int index = 0; index < presetRows.length; index += 1) {
      final List<String> values = presetRows[index];
      _rows[index] = FranckHertzMeasurementRow(
        index: index + 1,
        vg2kText: values[0],
        ipText: values[1],
      );
    }
    for (int index = presetRows.length; index < _rows.length; index += 1) {
      _rows[index] = FranckHertzMeasurementRow(
        index: index + 1,
        vg2kText: '',
        ipText: '',
      );
    }
    notifyListeners();
  }

  void clearAll() {
    bool changed = false;
    if (_vfText.isNotEmpty) {
      _vfText = '';
      changed = true;
    }
    if (_vg1kText.isNotEmpty) {
      _vg1kText = '';
      changed = true;
    }
    if (_vg2aText.isNotEmpty) {
      _vg2aText = '';
      changed = true;
    }
    if (_referenceVoltageText != defaultReferenceVoltageText) {
      _referenceVoltageText = defaultReferenceVoltageText;
      changed = true;
    }
    if (_rows.length != defaultRowCount) {
      _rows
        ..clear()
        ..addAll(
          List<FranckHertzMeasurementRow>.generate(
            defaultRowCount,
            (int index) => FranckHertzMeasurementRow(
              index: index + 1,
              vg2kText: '',
              ipText: '',
            ),
          ),
        );
      changed = true;
    } else {
      for (int index = 0; index < _rows.length; index += 1) {
        final FranckHertzMeasurementRow row = _rows[index];
        if (!row.hasAnyInput || row.index != index + 1) {
          if (row.index != index + 1) {
            _rows[index] = row.copyWith(index: index + 1);
            changed = true;
          }
          continue;
        }
        _rows[index] = FranckHertzMeasurementRow(
          index: index + 1,
          vg2kText: '',
          ipText: '',
        );
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool _isValidRowIndex(int rowIndex) {
    return rowIndex >= 0 && rowIndex < _rows.length;
  }

  FranckHertzAnalysisResult _buildAnalysisResult() {
    final List<FranckHertzDataPoint> validPoints = _buildValidPoints();
    final List<FranckHertzSmoothedPoint> smoothedPoints =
        _buildSmoothedPoints(validPoints);
    final FranckHertzMethodResult? peakResult = _buildMethodResult(
      smoothedPoints,
      isPeak: true,
    );
    final FranckHertzMethodResult? valleyResult = _buildMethodResult(
      smoothedPoints,
      isPeak: false,
    );
    final double? finalExcitationPotential =
        peakResult == null || valleyResult == null
            ? null
            : (peakResult.averageInterval + valleyResult.averageInterval) / 2;
    final double? referenceVoltage = _parsePositiveDouble(_referenceVoltageText);
    final double? relativeErrorPercent =
        finalExcitationPotential == null || referenceVoltage == null
            ? null
            : ((finalExcitationPotential - referenceVoltage).abs() /
                    referenceVoltage) *
                100;

    return FranckHertzAnalysisResult(
      validPoints: List<FranckHertzDataPoint>.unmodifiable(validPoints),
      smoothedPoints:
          List<FranckHertzSmoothedPoint>.unmodifiable(smoothedPoints),
      peakResult: peakResult,
      valleyResult: valleyResult,
      referenceVoltage: referenceVoltage,
      finalExcitationPotential: finalExcitationPotential,
      relativeErrorPercent: relativeErrorPercent,
    );
  }

  List<FranckHertzDataPoint> _buildValidPoints() {
    final List<FranckHertzDataPoint> points = <FranckHertzDataPoint>[];
    for (final FranckHertzMeasurementRow row in _rows) {
      final double? voltage = _parseDouble(row.vg2kText);
      final double? current = _parseDouble(row.ipText);
      if (voltage == null || current == null) {
        continue;
      }
      points.add(
        FranckHertzDataPoint(
          voltage: voltage,
          current: current,
        ),
      );
    }
    points.sort(
      (FranckHertzDataPoint a, FranckHertzDataPoint b) =>
          a.voltage.compareTo(b.voltage),
    );
    return points;
  }

  List<FranckHertzSmoothedPoint> _buildSmoothedPoints(
    List<FranckHertzDataPoint> validPoints,
  ) {
    if (validPoints.length < 5) {
      return const <FranckHertzSmoothedPoint>[];
    }

    final List<FranckHertzSmoothedPoint> points = <FranckHertzSmoothedPoint>[];
    for (int index = 2; index <= validPoints.length - 3; index += 1) {
      double currentSum = 0;
      for (int offset = -2; offset <= 2; offset += 1) {
        currentSum += validPoints[index + offset].current;
      }
      points.add(
        FranckHertzSmoothedPoint(
          voltage: validPoints[index].voltage,
          current: currentSum / 5,
        ),
      );
    }
    return points;
  }

  FranckHertzMethodResult? _buildMethodResult(
    List<FranckHertzSmoothedPoint> smoothedPoints, {
    required bool isPeak,
  }) {
    if (smoothedPoints.length < 3) {
      return null;
    }

    final List<FranckHertzFeaturePoint> featurePoints =
        <FranckHertzFeaturePoint>[];
    for (int index = 1; index < smoothedPoints.length - 1; index += 1) {
      final FranckHertzSmoothedPoint previous = smoothedPoints[index - 1];
      final FranckHertzSmoothedPoint current = smoothedPoints[index];
      final FranckHertzSmoothedPoint next = smoothedPoints[index + 1];
      final bool isTargetFeature = isPeak
          ? current.current > previous.current &&
              current.current > next.current
          : current.current < previous.current &&
              current.current < next.current;
      if (!isTargetFeature) {
        continue;
      }
      featurePoints.add(
        FranckHertzFeaturePoint(
          voltage: current.voltage,
          current: current.current,
        ),
      );
    }

    if (featurePoints.length < 2) {
      return null;
    }

    final List<double> intervals = <double>[];
    for (int index = 1; index < featurePoints.length; index += 1) {
      intervals.add(featurePoints[index].voltage - featurePoints[index - 1].voltage);
    }
    final double averageInterval =
        intervals.reduce((double a, double b) => a + b) / intervals.length;
    return FranckHertzMethodResult(
      featurePoints: List<FranckHertzFeaturePoint>.unmodifiable(featurePoints),
      intervals: List<double>.unmodifiable(intervals),
      averageInterval: averageInterval,
    );
  }

  double? _parseDouble(String text) {
    return double.tryParse(text.trim());
  }

  double? _parsePositiveDouble(String text) {
    final double? value = _parseDouble(text);
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }
}
