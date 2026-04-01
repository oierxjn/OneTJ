import 'package:get_it/get_it.dart';

import 'package:onetj/repo/app_update_state_repository.dart';
import 'package:onetj/services/app_update_api.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/external_launcher_service.dart';

final GetIt appLocator = GetIt.instance;

void configureDependencies() {
  // AppUpdateStateRepository
  // 单例
  if (!appLocator.isRegistered<AppUpdateStateRepository>()) {
    appLocator.registerLazySingleton<AppUpdateStateRepository>(
      AppUpdateStateRepository.getInstance,
    );
  }
  // AppUpdateApi
  // 单例
  if (!appLocator.isRegistered<AppUpdateApi>()) {
    appLocator.registerLazySingleton<AppUpdateApi>(
      AppUpdateApi.getInstance,
    );
  }
  // AppUpdateService
  // 单例
  if (!appLocator.isRegistered<AppUpdateService>()) {
    appLocator.registerLazySingleton<AppUpdateService>(
      () => AppUpdateService(
        api: appLocator<AppUpdateApi>(),
        repository: appLocator<AppUpdateStateRepository>(),
      ),
    );
  }
  // ExternalLauncherService
  if (!appLocator.isRegistered<ExternalLauncherService>()) {
    appLocator.registerLazySingleton<ExternalLauncherService>(
      ExternalLauncherService.getInstance,
    );
  }
}

Future<void> resetDependencies() {
  return appLocator.reset();
}
