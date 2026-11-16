/// 一次成功登出清理的结果。
///
/// 缓存与令牌清理失败不会产出本结果——登出被拒绝并抛
/// `LogoutCleanupException`。[residualFailures] 只可能是 Cookie 清理
/// 失败（步骤名 → 错误）：Cookie 不是缓存读取路径的数据源，残留不构成
/// 跨账号数据展示，故降级放行。非空表示登出已完成、会话已翻转为
/// 游客态，调用方应据此给出降级警告，而不是把登出当作失败。
class LogoutResult {
  LogoutResult({Map<String, Object> residualFailures = const <String, Object>{}})
      : residualFailures = Map<String, Object>.unmodifiable(residualFailures);

  final Map<String, Object> residualFailures;

  bool get isFullyClean => residualFailures.isEmpty;
}
