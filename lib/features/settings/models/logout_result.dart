/// 一次成功登出清理的结果。
///
/// [residualFailures] 只可能是 Cookie 清理失败
/// 调用方应据此给出降级警告，而不是把登出当作失败。
class LogoutResult {
  LogoutResult(
      {Map<String, Object> residualFailures = const <String, Object>{}})
      : residualFailures = Map<String, Object>.unmodifiable(residualFailures);

  final Map<String, Object> residualFailures;

  bool get isFullyClean => residualFailures.isEmpty;
}
