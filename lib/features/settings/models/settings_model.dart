import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/settings_validation.dart' as settings_validation;
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/repo/settings_repository.dart';

class SettingsModel {
  static void validateSettings(SettingsData settings) {
    validateMaxWeek(settings.maxWeek);
    validateTimeSlotRanges(settings.timeSlotRanges);
    validateDashboardUpcomingCount(settings.dashboardUpcomingCount);
  }

  /// 校验是否符合最大周数范围
  ///
  /// 最大周数范围为1-52
  ///
  /// throw [SettingsValidationException]
  static void validateMaxWeek(int value) {
    if (value < 1 || value > 52) {
      throw SettingsValidationException(
        code: SettingsValidationException.maxWeekOutOfRange,
        message: 'maxWeek out of range',
      );
    }
  }

  static void validateTimeSlotStartMinutes(List<int> values) {
    settings_validation.validateTimeSlotStartMinutes(values);
  }

  /// 从文本中解析最大周数
  ///
  /// throw [SettingsValidationException] 解析非数值
  static int parseMaxWeekText(String text) {
    return _parseInt(
      text: text,
      code: SettingsValidationException.maxWeekInvalidFormat,
      fieldName: 'maxWeek',
    );
  }

  /// 从文本中解析待办事项显示数量
  ///
  /// throw [SettingsValidationException] 解析非数值
  static int parseDashboardUpcomingCountText(String text) {
    return _parseInt(
      text: text,
      code: SettingsValidationException.dashboardUpcomingCountInvalidFormat,
      fieldName: 'dashboardUpcomingCount',
    );
  }

  static List<TimePeriodRangeData> buildTimeSlotRangesFromStartMinutes(
    List<int> starts,
  ) {
    return settings_validation.buildTimeSlotRangesFromStartMinutes(starts);
  }

  static void validateDashboardUpcomingCount(int value) {
    if (value < kMinDashboardUpcomingCount ||
        value > kMaxDashboardUpcomingCount) {
      throw SettingsValidationException(
        code: SettingsValidationException.dashboardUpcomingCountOutOfRange,
        message: 'dashboardUpcomingCount out of range',
      );
    }
  }

  /// 校验时间槽范围是否符合要求
  ///
  /// throw [SettingsValidationException]
  static void validateTimeSlotRanges(List<TimePeriodRangeData> values) {
    settings_validation.validateTimeSlotRanges(values);
  }

  /// 从文本中解析整数
  ///
  /// throw [SettingsValidationException] 解析非数值
  static int _parseInt({
    required String text,
    required String code,
    required String fieldName,
  }) {
    final int? value = int.tryParse(text.trim());
    if (value == null) {
      throw SettingsValidationException(
        code: code,
        message: '$fieldName is not a valid number',
      );
    }
    return value;
  }
}
