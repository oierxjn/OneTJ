import 'package:onetj/app/presentation/ui_event.dart';

/// 仪表盘本轮加载出现瞬时失败时发此事件。
///
/// 此事件允许请求重试。
class DashboardLoadFailedEvent extends UiEvent {
  const DashboardLoadFailedEvent();
}
