/// 波尔扭摆实验的计算结果。
///
/// 只承载已算出的数值，计算过程由 `BohrTwistPendulumViewModel` 负责。
class BohrTwistPendulumResult {
  const BohrTwistPendulumResult({
    required this.averagePeriod,
    required this.logMethodBeta,
    required this.graphicalBeta,
  });

  /// 自由振动平均周期 T（秒）。
  final double? averagePeriod;

  /// 对数逐差法得到的阻尼系数 β。
  final double? logMethodBeta;

  /// 作图法得到的阻尼系数 β。
  final double? graphicalBeta;

  bool get hasCompleteResult =>
      averagePeriod != null && logMethodBeta != null && graphicalBeta != null;
}
