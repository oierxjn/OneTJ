import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/settings/models/logout_result.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/webview_environment_service.dart';

/// 登出编排：清空会话相关的令牌、各功能缓存与 WebView Cookie。
///
/// 清理分两级（issue #64）：
/// * **关键步骤**：删除令牌。失败则异常上抛、不翻转状态——令牌仍在，
///   会话保持原态是自洽的，调用方提示失败即可。
/// * **尽力步骤**：各功能缓存与 Cookie。令牌删除成功后逐项容错，
///   单项失败记日志并继续，最终**必定**翻转会话状态，失败步骤记入
///   [LogoutResult.residualFailures] 供调用方降级提示。
///
/// 由此保证不出现「界面已登录、token 已删」的不一致窗口。
class LogoutService {
  LogoutService({
    required TokenRepository tokenRepository,
    required StudentInfoRepository studentInfoRepository,
    required SchoolCalendarRepository schoolCalendarRepository,
    required CourseScheduleRepository courseScheduleRepository,
    required CetScoreDataService cetScoreDataService,
    required GradesDataService gradesDataService,
    required StudentExamDataService studentExamDataService,
    required WebViewEnvironmentService webViewEnvironmentService,
    required SessionController sessionController,
    Future<void> Function()? clearTokenOverride,
    Future<void> Function()? clearStudentInfoOverride,
    Future<void> Function()? clearSchoolCalendarOverride,
    Future<void> Function()? clearCourseScheduleOverride,
    Future<void> Function()? clearCookiesOverride,
  })  : _clearToken = clearTokenOverride ?? tokenRepository.clearToken,
        _clearStudentInfo =
            clearStudentInfoOverride ?? studentInfoRepository.clearCache,
        _clearSchoolCalendar =
            clearSchoolCalendarOverride ?? schoolCalendarRepository.clearCache,
        _clearCourseSchedule =
            clearCourseScheduleOverride ?? courseScheduleRepository.clearCache,
        _cetScoreDataService = cetScoreDataService,
        _gradesDataService = gradesDataService,
        _studentExamDataService = studentExamDataService,
        _webViewEnvironment = webViewEnvironmentService.environment,
        _sessionController = sessionController,
        _clearCookiesOverride = clearCookiesOverride;

  final Future<void> Function() _clearToken;
  final Future<void> Function() _clearStudentInfo;
  final Future<void> Function() _clearSchoolCalendar;
  final Future<void> Function() _clearCourseSchedule;
  final CetScoreDataService _cetScoreDataService;
  final GradesDataService _gradesDataService;
  final StudentExamDataService _studentExamDataService;
  final WebViewEnvironment? _webViewEnvironment;
  final SessionController _sessionController;
  final Future<void> Function()? _clearCookiesOverride;

  /// 清空登录态数据并把会话标记为已登出（游客态）。
  ///
  /// 令牌删除失败时异常上抛且不翻转状态；令牌删除成功后无论尽力步骤
  /// 结果如何都会翻转状态，残留失败通过返回值告知调用方。
  Future<LogoutResult> clearSession() async {
    final LogoutResult result = await clearLocalSessionData();
    _sessionController.markSignedOut();
    return result;
  }

  /// 仅清空本机登录态相关数据（令牌/各功能缓存/WebView Cookie），不翻转
  /// 会话状态。供登出与「以游客身份继续」复用——后者清完再自行调
  /// [SessionController.continueAsGuest]。
  ///
  /// 令牌删除失败时异常上抛（此时未做任何清理，调用方不应翻转状态）；
  /// 其余步骤逐项容错，失败记入 [LogoutResult.residualFailures]。
  Future<LogoutResult> clearLocalSessionData() async {
    // 关键步骤：失败直接上抛，后续步骤不执行，状态由调用方保持原样。
    await _clearToken();

    final Map<String, Object> residualFailures = <String, Object>{};
    await _bestEffort('studentInfo', _clearStudentInfo, residualFailures);
    await _bestEffort('schoolCalendar', _clearSchoolCalendar, residualFailures);
    await _bestEffort(
        'courseSchedule', _clearCourseSchedule, residualFailures);
    await _bestEffort(
        'cetScore', _cetScoreDataService.clearCachedData, residualFailures);
    await _bestEffort(
        'grades', _gradesDataService.clearCachedData, residualFailures);
    await _bestEffort(
        'studentExams', _studentExamDataService.clearCachedData, residualFailures);
    await _bestEffort('cookies', _clearCookies, residualFailures);
    return LogoutResult(residualFailures: residualFailures);
  }

  Future<void> _clearCookies() async {
    final Future<void> Function()? override = _clearCookiesOverride;
    if (override != null) {
      await override();
      return;
    }
    await CookieManager.instance(webViewEnvironment: _webViewEnvironment)
        .deleteAllCookies();
  }

  /// 尽力清理一步：失败记警告日志并收集，不中断后续步骤。
  Future<void> _bestEffort(
    String step,
    Future<void> Function() action,
    Map<String, Object> failures,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      failures[step] = error;
      AppLogger.warning(
        'Logout cleanup step failed (best-effort, continuing)',
        loggerName: 'LogoutService',
        context: <String, Object?>{'step': step},
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
