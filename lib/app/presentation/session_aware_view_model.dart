import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 数据页视图模型的会话感知基类。
///
/// 收敛五个数据页（仪表盘/课表/成绩/四六级/考试）重复的会话样板：
/// 注入 [SessionController]、监听配对、游客态判断与状态迁移分发。
/// 只读会话状态，不翻转状态——状态写入由登录/登出/失效上报路径负责。
///
/// 状态迁移语义（与原各 VM 手写逻辑一致）：
/// * → authenticated（reason 为 login，即引导结束后的登录成功）：自动
///   [reloadAfterLogin]——绕过缓存 TTL 强刷，防止登出清理残留的上一账号
///   缓存被新账号读到（issue #64 审查发现）；课表 tab 常驻 IndexedStack，
///   initState 只跑一次，登录后全靠本监听重载；
/// * → authenticated（reason 为 boot，即冷启动判定已登录）：自动 [load]
///   ——本机缓存属于同一账号，走缓存优先即可；
/// * → guest：调 [clearPersonalData] 清空内存个人数据并通知——登出虽已清
///   磁盘缓存，存活的 VM 内存不清会泄漏上一账号数据；
/// * 其余状态（unknown/expired）：no-op。expired 保留缓存只读展示。
///
/// **不收进本基类的**（字段各异，留在子类）：load/refresh 入口的游客护栏
/// 与 await 后回写前的复检（防在途结果污染游客内存）、并发守卫。
abstract class SessionAwareViewModel<TEvent> extends BaseViewModel<TEvent> {
  SessionAwareViewModel({required SessionController sessionController})
      : _sessionController = sessionController {
    _sessionController.addListener(_onSessionChanged);
  }

  final SessionController _sessionController;

  /// 当前是否为游客态（无令牌，不应发起鉴权请求）。
  @protected
  bool get isGuest => _sessionController.status == AuthStatus.guest;

  /// 加载本页数据。子类自行编排（含游客护栏与回写复检）。
  Future<void> load();

  /// 引导结束后的登录成功触发的重载：子类应绕过缓存 TTL 强制刷新，
  /// 确保登出清理失败残留的上一账号缓存被新账号数据覆盖。
  ///
  /// 默认回落到 [load]（缓存优先），供无独立刷新能力的页面复用。
  /// 冷启动判定已登录（boot）不走本钩子——本机缓存属于同一账号。
  Future<void> reloadAfterLogin() => load();

  /// 清空内存中的个人数据，进入游客态时由基类调用。
  ///
  /// 只清字段，**不要**调 notifyListeners——基类清完统一通知。
  /// 本地设置等非个人数据应保留。
  @protected
  void clearPersonalData();

  void _onSessionChanged() {
    final AuthStatus status = _sessionController.status;
    if (status == AuthStatus.authenticated) {
      if (_sessionController.lastReason == 'login') {
        unawaited(reloadAfterLogin());
      } else {
        unawaited(load());
      }
    } else if (status == AuthStatus.guest) {
      clearPersonalData();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }
}