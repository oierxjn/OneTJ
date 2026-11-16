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

/// 个人数据缓存清理失败，登出被拒绝。此时令牌未动、会话保持原态，
/// 避免残留缓存被下一个登录账号读到。
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

/// 登出编排：先清各功能缓存，再删令牌，最后清 Cookie。
///
/// 缓存或令牌清理失败即拒绝登出（抛 [LogoutCleanupException]，会话不
/// 翻转）；Cookie 失败仅记入 [LogoutResult.residualFailures]，不阻塞。
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
  Future<LogoutResult> clearSession() async {
    final LogoutResult result = await clearLocalSessionData();
    _sessionController.markSignedOut();
    return result;
  }

  /// 仅清空本机登录态相关数据，不翻转会话状态。供登出与「以游客身份
  /// 继续」复用，后者清完再自行调 [SessionController.continueAsGuest]。
  Future<LogoutResult> clearLocalSessionData() async {
    // 逐项清缓存，失败不中断其余，最后统一裁决。
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
      throw LogoutCleanupException(failedSteps: cacheFailures);
    }

    // 缓存全部干净后才删令牌。
    await _tokenRepository.clearToken();

    // Cookie 失败降级为警告，不阻塞登出。
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

  /// 清一个缓存域，失败记日志并收集步骤名。
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
