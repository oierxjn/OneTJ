/// 一次登出清理的结果。
///
/// [residualFailures] 是令牌删除成功后仍失败的尽力清理步骤
/// （步骤名 → 错误）。非空表示登出已完成、会话已翻转为游客态，
/// 但本机可能残留少量缓存/Cookie；调用方应据此给出降级警告，
/// 而不是把登出当作失败。
class LogoutResult {
  const LogoutResult({this.residualFailures = const <String, Object>{}});

  final Map<String, Object> residualFailures;

  bool get isFullyClean => residualFailures.isEmpty;
}
