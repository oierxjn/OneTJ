import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/app_lifecycle_host.dart';
import 'package:onetj/services/app_update_service.dart';

void main() {
  testWidgets('resumed 时会调用注入的更新恢复逻辑', (tester) async {
    final TestAppUpdateService service = TestAppUpdateService();

    await tester.pumpWidget(
      MaterialApp(
        home: AppLifecycleHost(
          appUpdateService: service,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(service.resumePendingInstallCallCount, 1);
  });

  testWidgets('resumed 时记录更新恢复失败', (tester) async {
    final Object error = Exception('resume failed');
    final TestAppUpdateService service = TestAppUpdateService(
      onResumePendingInstall: () async => throw error,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppLifecycleHost(
          appUpdateService: service,
          child: const SizedBox.shrink(),
        ),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(service.resumePendingInstallCallCount, 1);
    expect(service.loggedErrors, hasLength(1));
    expect(service.loggedErrors.single, same(error));
  });
}

class TestAppUpdateService implements AppUpdateService {
  TestAppUpdateService({
    this.onResumePendingInstall,
  });

  final Future<void> Function()? onResumePendingInstall;
  int resumePendingInstallCallCount = 0;
  final List<Object> loggedErrors = <Object>[];

  @override
  Future<void> resumePendingInstall() async {
    resumePendingInstallCallCount += 1;
    await onResumePendingInstall?.call();
  }

  @override
  void logUpdateFailure(Object error, StackTrace stackTrace) {
    loggedErrors.add(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
