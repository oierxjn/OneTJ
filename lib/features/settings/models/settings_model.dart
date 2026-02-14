import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/repo/settings_repository.dart';

class SettingsModel {
  static void validateSettings(SettingsData settings) {
    validateMaxWeek(settings.maxWeek);
    validateTimeSlotStartMinutes(settings.timeSlotStartMinutes);
  }

  static void validateMaxWeek(int value) {
    if (value < 1 || value > 52) {
      throw SettingsResolveException(message: 'maxWeek out of range');
    }
  }

  static void validateTimeSlotStartMinutes(List<int> values) {
    if (values.isEmpty) {
      throw SettingsResolveException(
        message: 'timeSlotStartMinutes must not be empty',
      );
    }
    for (int i = 0; i < values.length; i += 1) {
      final int minute = values[i];
      if (minute < 0 || minute > 24 * 60 - 1) {
        throw SettingsResolveException(
          message: 'timeSlotStartMinutes item out of range',
        );
      }
      if (i > 0 && minute <= values[i - 1]) {
        throw SettingsResolveException(
          message: 'timeSlotStartMinutes must be strictly increasing',
        );
      }
    }
  }
}
