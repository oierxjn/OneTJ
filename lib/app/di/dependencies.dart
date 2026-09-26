import 'package:get_it/get_it.dart';

import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/student_exams/application/student_exam_data_service.dart';
import 'package:onetj/features/timetable/application/timetable_data_service.dart';
import 'package:onetj/features/physics_lab/features/michelson/application/michelson_draft_service.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/application/diffraction_grating_draft_service.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/application/franck_hertz_draft_service.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/application/bohr_twist_pendulum_draft_service.dart';
import 'package:onetj/repo/app_update_state_repository.dart';
import 'package:onetj/repo/cet_score_repository.dart';
import 'package:onetj/repo/color_preset_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_exam_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/template_repository.dart';
import 'package:onetj/repo/theme_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';
import 'package:onetj/services/app_update_api.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/external_launcher_service.dart';
import 'package:onetj/services/term_key_resolver.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/user_collection_service.dart';
import 'package:onetj/services/webview_environment_service.dart';

final GetIt appLocator = GetIt.instance;

void configureDependencies() {
  // Repositories
  appLocator.registerLazySingleton<TokenRepository>(TokenRepository.new);
  appLocator.registerLazySingleton<SettingsRepository>(SettingsRepository.new);
  appLocator.registerLazySingleton<ThemeRepository>(ThemeRepository.new);
  appLocator.registerLazySingleton<CetScoreRepository>(CetScoreRepository.new);
  appLocator.registerLazySingleton<StudentExamRepository>(
    StudentExamRepository.new,
  );
  appLocator.registerLazySingleton<ColorPresetRepository>(
    ColorPresetRepository.new,
  );
  appLocator.registerLazySingleton<StudentInfoRepository>(
    StudentInfoRepository.new,
  );
  appLocator.registerLazySingleton<SchoolCalendarRepository>(
    SchoolCalendarRepository.new,
  );
  appLocator.registerLazySingleton<CourseScheduleRepository>(
    CourseScheduleRepository.new,
  );
  appLocator.registerLazySingleton<UndergraduateScoreRepository>(
    UndergraduateScoreRepository.new,
  );
  appLocator.registerLazySingleton<TemplateRepository>(TemplateRepository.new);
  appLocator.registerLazySingleton<AppUpdateStateRepository>(
    AppUpdateStateRepository.new,
  );
  appLocator.registerLazySingleton<PhysicsLabDraftRepository>(
    PhysicsLabDraftRepository.new,
  );

  // Services
  appLocator.registerLazySingleton<AuthTokenProvider>(
    () => AuthTokenProvider(repository: appLocator<TokenRepository>()),
  );
  appLocator.registerLazySingleton<AppUpdateApi>(AppUpdateApi.new);
  appLocator.registerLazySingleton<AppUpdateService>(
    () => AppUpdateService(
      api: appLocator<AppUpdateApi>(),
      repository: appLocator<AppUpdateStateRepository>(),
    ),
  );
  appLocator.registerLazySingleton<ExternalLauncherService>(
    ExternalLauncherService.new,
  );
  appLocator.registerLazySingleton<WebViewEnvironmentService>(
    WebViewEnvironmentService.new,
  );
  appLocator.registerLazySingleton<TongjiApi>(
    () => TongjiApi(auth: appLocator<AuthTokenProvider>()),
  );
  appLocator.registerLazySingleton<UserCollectionService>(
    UserCollectionService.new,
  );
  appLocator.registerLazySingleton<TermKeyResolver>(
    () => TermKeyResolver(
      calendarRepository: appLocator<SchoolCalendarRepository>(),
      scheduleRepository: appLocator<CourseScheduleRepository>(),
    ),
  );
  appLocator.registerLazySingleton<DashboardDataService>(
    () => DashboardDataService(
      api: appLocator<TongjiApi>(),
      termKeyResolver: appLocator<TermKeyResolver>(),
      studentInfoRepository: appLocator<StudentInfoRepository>(),
      courseScheduleRepository: appLocator<CourseScheduleRepository>(),
    ),
  );
  appLocator.registerLazySingleton<GradesDataService>(
    () => GradesDataService(
      api: appLocator<TongjiApi>(),
      repository: appLocator<UndergraduateScoreRepository>(),
    ),
  );
  appLocator.registerLazySingleton<TimetableDataService>(
    () => TimetableDataService(
      api: appLocator<TongjiApi>(),
      scheduleRepository: appLocator<CourseScheduleRepository>(),
      calendarRepository: appLocator<SchoolCalendarRepository>(),
      termKeyResolver: appLocator<TermKeyResolver>(),
    ),
  );
  appLocator.registerLazySingleton<CetScoreDataService>(
    () => CetScoreDataService(
      api: appLocator<TongjiApi>(),
      repository: appLocator<CetScoreRepository>(),
    ),
  );
  appLocator.registerLazySingleton<StudentExamDataService>(
    () => StudentExamDataService(
      api: appLocator<TongjiApi>(),
      repository: appLocator<StudentExamRepository>(),
    ),
  );
  appLocator.registerLazySingleton<MichelsonDraftService>(
    () => MichelsonDraftService(
      repository: appLocator<PhysicsLabDraftRepository>(),
    ),
  );
  appLocator.registerLazySingleton<DiffractionGratingDraftService>(
    () => DiffractionGratingDraftService(
      repository: appLocator<PhysicsLabDraftRepository>(),
    ),
  );
  appLocator.registerLazySingleton<FranckHertzDraftService>(
    () => FranckHertzDraftService(
      repository: appLocator<PhysicsLabDraftRepository>(),
    ),
  );
  appLocator.registerLazySingleton<BohrTwistPendulumDraftService>(
    () => BohrTwistPendulumDraftService(
      repository: appLocator<PhysicsLabDraftRepository>(),
    ),
  );

  // Theme
  appLocator.registerLazySingleton<ThemeChangeNotifier>(
    () => ThemeChangeNotifier(repository: appLocator<ThemeRepository>()),
  );
}

Future<void> resetDependencies() {
  return appLocator.reset();
}
