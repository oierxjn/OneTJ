import 'package:onetj/app/exception/app_exception.dart';
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
import 'package:onetj/services/cookie_clearer.dart';

/// 个人数据缓存清理失败：登出/进入游客态被拒绝。
///
/// 不变式：**进入游客态 ⇒ 本机无个人数据缓存**。缓存清不干净就不允许
/// 登出——否则残留缓存会在 TTL 内被下一个登录账号读到（跨账号隐私窗口，
/// 且详情页/冷启动/埋点等路径无法靠登录瞬间的强刷兜住）。此时令牌未动、
/// 会话保持原态，用户重试即可；失败步骤已逐项记日志。
class LogoutCleanupException extends AppException {
  static const String errorCode = 'LOGOUT_CLEANUP_FAILED';

  LogoutCleanupException({required this.failedSteps})
      : super(
          errorCode,
          'Logout refused: local data cleanup failed '
          '(${failedSteps.join(', ')}), please retry',
        );

  final List<String> failedSteps;
}

/// 登出编排：清空会话相关的令牌、各功能缓存与 WebView Cookie。
///
/// 清理顺序与失败语义（issue #64，全有或全无）：
/// 1. **先清各功能缓存**：逐项尝试、失败不中断其余（便于一次重试清完），
///    任一项失败则收集后抛 [LogoutCleanupException]——令牌未动、会话不
///    翻转，登出被拒绝。
/// 2. **缓存全部干净后删令牌**：失败同样上抛不翻转（缓存已空但令牌仍在，
///    会话保持原态是自洽的，重试时缓存清理为幂等空操作）。
/// 3. **Cookie 最后清，失败降级**：Cookie 不是缓存读取路径的数据源，
///    残留只影响 WebView 下次登录的会话预填，不构成跨账号数据展示；
///    失败记入 [LogoutResult.residualFailures] 供调用方警告，不阻塞登出。
/// 4. 令牌删除成功即翻转状态（[clearSession] 调 markSignedOut）。
class LogoutService {
  LogoutService({
    required TokenRepository tokenRepository,
    required StudentInfoRepository studentInfoRepository,
    required SchoolCalendarRepository schoolCalendarRepository,
    required CourseScheduleRepository courseScheduleRepository,
    required CetScoreDataService cetScoreDataService,
    required GradesDataService gradesDataService,
    required StudentExamDataService studentExamDataService,
    required CookieClearer cookieClearer,
    required SessionController sessionController,
  })  : _tokenRepository = tokenRepository,
        _studentInfoRepository = studentInfoRepository,
        _schoolCalendarRepository = schoolCalendarRepository,
        _courseScheduleRepository = courseScheduleRepository,
        _cetScoreDataService = cetScoreDataService,
        _gradesDataService = gradesDataService,
        _studentExamDataService = studentExamDataService,
        _cookieClearer = cookieClearer,
        _sessionController = sessionController;

  final TokenRepository _tokenRepository;
  final StudentInfoRepository _studentInfoRepository;
  final SchoolCalendarRepository _schoolCalendarRepository;
  final CourseScheduleRepository _courseScheduleRepository;
  final CetScoreDataService _cetScoreDataService;
  final GradesDataService _gradesDataService;
  final StudentExamDataService _studentExamDataService;
  final CookieClearer _cookieClearer;
  final SessionController _sessionController;

  /// 清空登录态数据并把会话标记为已登出（游客态）。
  ///
  /// 缓存或令牌清理失败时异常上抛且不翻转状态（登出被拒绝）；
  /// 仅 Cookie 残留失败时仍翻转，失败通过返回值告知调用方降级警告。
  Future<LogoutResult> clearSession() async {
    final LogoutResult result = await clearLocalSessionData();
    _sessionController.markSignedOut();
    return result;
  }

  /// 仅清空本机登录态相关数据，不翻转会话状态。供登出与「以游客身份
  /// 继续」复用——后者清完再自行调 [SessionController.continueAsGuest]。
  ///
  /// 失败语义与 [clearSession] 一致：缓存/令牌失败上抛（调用方不得翻转
  /// 状态），Cookie 失败记入 [LogoutResult.residualFailures]。
  Future<LogoutResult> clearLocalSessionData() async {
    // 第一步：清各功能缓存。逐项尝试，失败不中断其余，最后统一裁决。
    final List<String> cacheFailures = <String>[];
    await _tryCacheClear(
        'studentInfo', _studentInfoRepository.clearCache, cacheFailures);
    await _tryCacheClear(
        'schoolCalendar', _schoolCalendarRepository.clearCache, cacheFailures);
    await _tryCacheClear(
        'courseSchedule', _courseScheduleRepository.clearCache, cacheFailures);
    await _tryCacheClear(
        'cetScore', _cetScoreDataService.clearCachedData, cacheFailures);
    await _tryCacheClear(
        'grades', _gradesDataService.clearCachedData, cacheFailures);
    await _tryCacheClear(
        'studentExams', _studentExamDataService.clearCachedData, cacheFailures);
    if (cacheFailures.isNotEmpty) {
      // 缓存清不干净 ⇒ 拒绝登出。令牌未动，会话保持原态。
      throw LogoutCleanupException(failedSteps: cacheFailures);
    }

    // 第二步：缓存全部干净后才删令牌。失败上抛，状态同样不翻转。
    await _tokenRepository.clearToken();

    // 第三步：Cookie 尽力清理，失败降级为警告，不阻塞登出。
    final Map<String, Object> residualFailures = <String, Object>{};
    try {
      await _cookieClearer.deleteAllCookies();
    } catch (error, stackTrace) {
      residualFailures['cookies'] = error;
      AppLogger.warning(
        'Cookie cleanup failed during logout (degraded, continuing)',
        loggerName: 'LogoutService',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return LogoutResult(residualFailures: residualFailures);
  }

  /// 尝试清一个缓存域：失败记警告日志并收集步骤名，不中断其余步骤。
  Future<void> _tryCacheClear(
    String step,
    Future<void> Function() action,
    List<String> failures,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      failures.add(step);
      AppLogger.warning(
        'Logout cache cleanup failed (logout will be refused)',
        loggerName: 'LogoutService',
        context: <String, Object?>{'step': step},
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
