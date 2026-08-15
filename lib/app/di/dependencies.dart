import 'package:get_it/get_it.dart';

import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/cet_score/application/cet_score_data_service.dart';
import 'package:onetj/features/cet_score/view_models/cet_score_view_model.dart';
import 'package:onetj/repo/app_update_state_repository.dart';
import 'package:onetj/repo/cet_score_repository.dart';
import 'package:onetj/repo/color_preset_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/template_repository.dart';
import 'package:onetj/repo/theme_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/repo/undergraduate_score_repository.dart';
import 'package:onetj/services/app_update_api.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/external_launcher_service.dart';
import 'package:onetj/services/tongji.dart';

final GetIt appLocator = GetIt.instance;

void configureDependencies() {
  // Repositories
  appLocator.registerLazySingleton<TokenRepository>(TokenRepository.new);
  appLocator.registerLazySingleton<SettingsRepository>(SettingsRepository.new);
  appLocator.registerLazySingleton<ThemeRepository>(ThemeRepository.new);
  appLocator.registerLazySingleton<CetScoreRepository>(CetScoreRepository.new);
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
  appLocator.registerLazySingleton<TongjiApi>(TongjiApi.new);
  appLocator.registerLazySingleton<CetScoreDataService>(
    () => CetScoreDataService(
      api: appLocator<TongjiApi>(),
      repository: appLocator<CetScoreRepository>(),
    ),
  );
  appLocator.registerFactory<CetScoreViewModel>(
    () => CetScoreViewModel(dataSource: appLocator<CetScoreDataService>()),
  );

  // Theme
  appLocator.registerLazySingleton<ThemeChangeNotifier>(
    ThemeChangeNotifier.new,
  );
}

Future<void> resetDependencies() {
  return appLocator.reset();
}
