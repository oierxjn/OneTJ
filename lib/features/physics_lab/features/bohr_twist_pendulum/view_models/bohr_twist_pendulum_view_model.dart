import 'dart:math' as math;

import 'package:onetj/features/physics_lab/draft_save_coordinator.dart';
import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/application/bohr_twist_pendulum_draft_service.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/models/bohr_twist_pendulum_draft.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/models/bohr_twist_pendulum_result.dart';

/// 波尔扭摆实验的状态持有者。
///
/// 输入为自由振动周期（或周期表格数据）与阻尼振动振幅表格数据，计算逻辑与
/// 原 HarmonyOS 端的 `BohrTwistPendulum` / `DataProcess` 保持一致：
/// 对数逐差法与作图法分别求阻尼系数 β。
class BohrTwistPendulumViewModel extends BaseViewModel<Never> {
  BohrTwistPendulumViewModel({BohrTwistPendulumDraftService? draftService})
      : _draftService = draftService {
    _saveCoordinator = DraftSaveCoordinator(_persistNow);
  }

  /// 对数逐差法中相邻振幅的间隔数（θₙ 与 θₙ₊₅）。
  static const int numberOfIntervals = 5;

  /// 表格数据的列数（序号、振幅、周期 / 序号、θₙ、θₙ₊₅）。
  static const int columnCount = 3;

  static const String defaultPeriodText = '1.5700';
  static const String defaultPeriodTableText =
      '1 160 1.5625\n2 159 1.5626\n3 158 1.5627';
  static const String defaultAmplitudeTableText =
      '1 173 102\n2 156 91\n3 140 82\n4 126 73\n5 114 66';

  String _periodText = defaultPeriodText;
  String _periodTableText = defaultPeriodTableText;
  String _amplitudeTableText = defaultAmplitudeTableText;

  final BohrTwistPendulumDraftService? _draftService;
  late final DraftSaveCoordinator _saveCoordinator;

  String get periodText => _periodText;
  String get periodTableText => _periodTableText;
  String get amplitudeTableText => _amplitudeTableText;

  BohrTwistPendulumResult get result => _buildResult();

  bool get hasAnyInput =>
      _periodText.trim().isNotEmpty ||
      _periodTableText.trim().isNotEmpty ||
      _amplitudeTableText.trim().isNotEmpty;

  void updatePeriodText(String value) {
    if (_periodText == value) {
      return;
    }
    _periodText = value;
    _saveCoordinator.markEdited();
    notifyListeners();
  }

  void updatePeriodTableText(String value) {
    if (_periodTableText == value) {
      return;
    }
    _periodTableText = value;
    _saveCoordinator.markEdited();
    notifyListeners();
  }

  void updateAmplitudeTableText(String value) {
    if (_amplitudeTableText == value) {
      return;
    }
    _amplitudeTableText = value;
    _saveCoordinator.markEdited();
    notifyListeners();
  }

  void applyDefaultPreset() {
    bool changed = false;
    if (_periodText != defaultPeriodText) {
      _periodText = defaultPeriodText;
      changed = true;
    }
    if (_periodTableText != defaultPeriodTableText) {
      _periodTableText = defaultPeriodTableText;
      changed = true;
    }
    if (_amplitudeTableText != defaultAmplitudeTableText) {
      _amplitudeTableText = defaultAmplitudeTableText;
      changed = true;
    }
    if (changed) {
      _saveCoordinator.markEdited();
      notifyListeners();
    }
  }

  void clearAll() {
    bool changed = false;
    if (_periodText.isNotEmpty) {
      _periodText = '';
      changed = true;
    }
    if (_periodTableText.isNotEmpty) {
      _periodTableText = '';
      changed = true;
    }
    if (_amplitudeTableText.isNotEmpty) {
      _amplitudeTableText = '';
      changed = true;
    }
    if (changed) {
      _saveCoordinator.markEdited();
      notifyListeners();
    }
  }

  Future<void> load() async {
    final BohrTwistPendulumDraftService? service = _draftService;
    if (service == null) {
      return;
    }
    final int versionAtStart = _saveCoordinator.editVersion;
    final BohrTwistPendulumDraft? draft = await service.load();
    if (draft == null) {
      return;
    }
    if (_saveCoordinator.editVersion != versionAtStart) {
      return;
    }
    _periodText = draft.periodText;
    _periodTableText = draft.periodTableText;
    _amplitudeTableText = draft.amplitudeTableText;
    notifyListeners();
  }

  Future<void> _persistNow() {
    final BohrTwistPendulumDraftService? service = _draftService;
    if (service == null) {
      return Future<void>.value();
    }
    return service.save(
      BohrTwistPendulumDraft(
        periodText: _periodText,
        periodTableText: _periodTableText,
        amplitudeTableText: _amplitudeTableText,
      ),
    );
  }

  BohrTwistPendulumResult _buildResult() {
    final double? averagePeriod = _buildAveragePeriod();
    final List<List<String>> amplitudeRows =
        _parseTableRows(_amplitudeTableText);
    double? logMethodBeta;
    double? graphicalBeta;
    if (averagePeriod != null && amplitudeRows.isNotEmpty) {
      logMethodBeta = _buildLogMethodBeta(amplitudeRows, averagePeriod);
      graphicalBeta = _buildGraphicalBeta(amplitudeRows, averagePeriod);
    }
    return BohrTwistPendulumResult(
      averagePeriod: averagePeriod,
      logMethodBeta: logMethodBeta,
      graphicalBeta: graphicalBeta,
    );
  }

  /// 优先从周期表格数据的第 3 列求平均周期；表格为空时回退到单行周期。
  double? _buildAveragePeriod() {
    final double? tableAverage = _averageOfThirdColumn(_periodTableText);
    if (tableAverage != null) {
      return tableAverage;
    }
    final double? fallback = double.tryParse(_periodText.trim());
    if (fallback == null || fallback <= 0) {
      return null;
    }
    return fallback;
  }

  double? _averageOfThirdColumn(String text) {
    final List<List<String>> rows = _parseTableRows(text);
    if (rows.isEmpty) {
      return null;
    }
    final List<double> values = <double>[];
    for (final List<String> row in rows) {
      final double? value = double.tryParse(row[2].trim());
      if (value != null) {
        values.add(value);
      }
    }
    if (values.isEmpty) {
      return null;
    }
    final double average =
        values.reduce((double a, double b) => a + b) / values.length;
    if (average <= 0) {
      return null;
    }
    return average;
  }

  /// 对数逐差法：β = Σ[(ln θₙ − ln θₙ₊₅)/(5T)] / N。
  double? _buildLogMethodBeta(
    List<List<String>> amplitudeRows,
    double averagePeriod,
  ) {
    final List<double> values = <double>[];
    for (final List<String> row in amplitudeRows) {
      final double? thetaN = _parsePositiveDouble(row[1]);
      final double? thetaNPlus = _parsePositiveDouble(row[2]);
      if (thetaN == null || thetaNPlus == null) {
        continue;
      }
      values.add(
        (math.log(thetaN) - math.log(thetaNPlus)) /
            numberOfIntervals /
            averagePeriod,
      );
    }
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((double a, double b) => a + b) / values.length;
  }

  /// 作图法：对 (n, ln θₙ) 与 (n+5, ln θₙ₊₅) 做最小二乘拟合，β = −k/T。
  double? _buildGraphicalBeta(
    List<List<String>> amplitudeRows,
    double averagePeriod,
  ) {
    final List<_DataDot> points = <_DataDot>[];
    for (final List<String> row in amplitudeRows) {
      final int? index = int.tryParse(row[0].trim());
      final double? thetaN = _parsePositiveDouble(row[1]);
      final double? thetaNPlus = _parsePositiveDouble(row[2]);
      if (index == null || thetaN == null || thetaNPlus == null) {
        continue;
      }
      points.add(_DataDot(index.toDouble(), math.log(thetaN)));
      points.add(
        _DataDot((index + numberOfIntervals).toDouble(), math.log(thetaNPlus)),
      );
    }
    if (points.length < 2) {
      return null;
    }
    final double slope = _leastSquaresSlope(points);
    return -slope / averagePeriod;
  }

  /// 最小二乘拟合直线 Y = C + kX 的斜率 k。
  double _leastSquaresSlope(List<_DataDot> points) {
    final int count = points.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;
    for (final _DataDot point in points) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumX2 += point.x * point.x;
    }
    final double denominator = count * sumX2 - sumX * sumX;
    if (denominator == 0) {
      return 0;
    }
    return (count * sumXY - sumX * sumY) / denominator;
  }

  /// 将空白分隔的线性数据按 [columnCount] 列分组为行，丢弃不足一列的尾部。
  List<List<String>> _parseTableRows(String text) {
    final List<String> tokens = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
    final List<List<String>> rows = <List<String>>[];
    List<String> current = <String>[];
    for (final String token in tokens) {
      current.add(token);
      if (current.length == columnCount) {
        rows.add(current);
        current = <String>[];
      }
    }
    return rows;
  }

  double? _parsePositiveDouble(String text) {
    final double? value = double.tryParse(text.trim());
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }
}

class _DataDot {
  const _DataDot(this.x, this.y);

  final double x;
  final double y;
}
