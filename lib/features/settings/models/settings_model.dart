import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/settings_validation.dart' as settings_validation;
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/repo/settings_repository.dart';

class SettingsModel {
  static void validateSettings(SettingsData settings) {
    validateMaxWeek(settings.maxWeek);
    validateTimeSlotRanges(settings.timeSlotRanges);
  }

  static void validateMaxWeek(int value) {
    if (value < 1 || value > 52) {
      throw SettingsResolveException(message: 'maxWeek out of range');
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

  static void validateTimeSlotRanges(List<TimePeriodRangeData> values) {
    settings_validation.validateTimeSlotRanges(values);
  }
}
