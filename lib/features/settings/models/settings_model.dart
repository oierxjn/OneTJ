import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/settings_validation.dart' as settings_validation;
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/repo/settings_repository.dart';

class SettingsModel {
  static void validateSettings(SettingsData settings) {
    validateMaxWeek(settings.maxWeek);
    validateTimeSlotRanges(settings.timeSlotRanges);
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

  static List<TimePeriodRangeData> buildTimeSlotRangesFromStartMinutes(
    List<int> starts,
  ) {
    return settings_validation.buildTimeSlotRangesFromStartMinutes(starts);
  }
  /// 校验时间槽范围是否符合要求
  /// 
  /// throw [SettingsValidationException]
  static void validateTimeSlotRanges(List<TimePeriodRangeData> values) {
    settings_validation.validateTimeSlotRanges(values);
  }
}
