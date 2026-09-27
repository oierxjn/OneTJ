import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/webview_environment_service.dart';

/// 登出编排：清空会话相关的令牌、各功能缓存与 WebView Cookie。
///
/// 单一职责是「把本机与登录态相关的数据恢复为未登录状态」，
/// 具体包含哪些仓库由本服务掌握，调用方只需发起一次 [clearSession]。
class LogoutService {
  LogoutService({
    required TokenRepository tokenRepository,
    required StudentInfoRepository studentInfoRepository,
    required SchoolCalendarRepository schoolCalendarRepository,
    required CourseScheduleRepository courseScheduleRepository,
    required CetScoreDataService cetScoreDataService,
    required WebViewEnvironmentService webViewEnvironmentService,
  })  : _tokenRepository = tokenRepository,
        _studentInfoRepository = studentInfoRepository,
        _schoolCalendarRepository = schoolCalendarRepository,
        _courseScheduleRepository = courseScheduleRepository,
        _cetScoreDataService = cetScoreDataService,
        _webViewEnvironment = webViewEnvironmentService.environment;

  final TokenRepository _tokenRepository;
  final StudentInfoRepository _studentInfoRepository;
  final SchoolCalendarRepository _schoolCalendarRepository;
  final CourseScheduleRepository _courseScheduleRepository;
  final CetScoreDataService _cetScoreDataService;
  final WebViewEnvironment? _webViewEnvironment;

  /// 清空登录令牌、各功能缓存与 WebView Cookie。
  ///
  /// 任意一步失败都会向上抛出，由调用方决定如何提示用户。
  Future<void> clearSession() async {
    await _tokenRepository.clearToken();
    await _studentInfoRepository.clearCache();
    await _schoolCalendarRepository.clearCache();
    await _courseScheduleRepository.clearCache();
    await _cetScoreDataService.clearCachedData();
    await CookieManager.instance(webViewEnvironment: _webViewEnvironment)
        .deleteAllCookies();
  }
}
