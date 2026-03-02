import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/settings/models/settings_model.dart';

void main() {
  group('SettingsModel.parseMaxWeekText', () {
    test('parses valid number', () {
      expect(SettingsModel.parseMaxWeekText('12'), 12);
      expect(SettingsModel.parseMaxWeekText(' 7 '), 7);
    });

    test('throws invalid format for empty or non-number', () {
      expect(
        () => SettingsModel.parseMaxWeekText(''),
        throwsA(
          isA<SettingsValidationException>().having(
            (e) => e.code,
            'code',
            SettingsValidationException.maxWeekInvalidFormat,
          ),
        ),
      );
      expect(
        () => SettingsModel.parseMaxWeekText('abc'),
        throwsA(
          isA<SettingsValidationException>().having(
            (e) => e.code,
            'code',
            SettingsValidationException.maxWeekInvalidFormat,
          ),
        ),
      );
    });
  });

  group('SettingsModel.parseDashboardUpcomingCountText', () {
    test('parses valid number', () {
      expect(SettingsModel.parseDashboardUpcomingCountText('3'), 3);
      expect(SettingsModel.parseDashboardUpcomingCountText(' 10 '), 10);
    });

    test('throws invalid format for empty or non-number', () {
      expect(
        () => SettingsModel.parseDashboardUpcomingCountText(''),
        throwsA(
          isA<SettingsValidationException>().having(
            (e) => e.code,
            'code',
            SettingsValidationException.dashboardUpcomingCountInvalidFormat,
          ),
        ),
      );
      expect(
        () => SettingsModel.parseDashboardUpcomingCountText('abc'),
        throwsA(
          isA<SettingsValidationException>().having(
            (e) => e.code,
            'code',
            SettingsValidationException.dashboardUpcomingCountInvalidFormat,
          ),
        ),
      );
    });
  });

  group('SettingsModel.validateDashboardUpcomingCount', () {
    test('accepts value within range', () {
      expect(
        () => SettingsModel.validateDashboardUpcomingCount(1),
        returnsNormally,
      );
      expect(
        () => SettingsModel.validateDashboardUpcomingCount(20),
        returnsNormally,
      );
    });

    test('throws for out-of-range value', () {
      expect(
        () => SettingsModel.validateDashboardUpcomingCount(0),
        throwsA(
          isA<SettingsValidationException>().having(
            (e) => e.code,
            'code',
            SettingsValidationException.dashboardUpcomingCountOutOfRange,
          ),
        ),
      );
      expect(
        () => SettingsModel.validateDashboardUpcomingCount(21),
        throwsA(
          isA<SettingsValidationException>().having(
            (e) => e.code,
            'code',
            SettingsValidationException.dashboardUpcomingCountOutOfRange,
          ),
        ),
      );
    });
  });
}
