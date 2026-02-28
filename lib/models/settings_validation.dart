import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/time_period_range.dart';

void validateTimeSlotRanges(List<TimePeriodRangeData> ranges) {
  if (ranges.isEmpty) {
    throw SettingsResolveException(
      message: 'timeSlotRanges must not be empty',
    );
  }
  for (int i = 0; i < ranges.length; i += 1) {
    final int start = ranges[i].startMinutes;
    final int end = ranges[i].endMinutes;
    if (start < 0 || start > 24 * 60) {
      throw SettingsResolveException(
        message: 'timeSlotRanges.startMinutes out of range',
      );
    }
    if (end < 0 || end > 24 * 60) {
      throw SettingsResolveException(
        message: 'timeSlotRanges.endMinutes out of range',
      );
    }
    if (start >= end) {
      throw SettingsResolveException(
        message: 'timeSlotRanges.startMinutes must be less than endMinutes',
      );
    }
    if (i > 0) {
      final TimePeriodRangeData prev = ranges[i - 1];
      if (prev.startMinutes >= start) {
        throw SettingsResolveException(
          message: 'timeSlotRanges.startMinutes must be strictly increasing',
        );
      }
      if (prev.endMinutes > start) {
        throw SettingsResolveException(
          message: 'timeSlotRanges must not overlap',
        );
      }
    }
  }
}

void validateTimeSlotStartMinutes(List<int> values) {
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

List<TimePeriodRangeData> buildTimeSlotRangesFromStartMinutes(
  List<int> starts, {
  int lastDurationMinutes = kLegacyTimeSlotLastDurationMinutes,
}) {
  validateTimeSlotStartMinutes(starts);
  final List<TimePeriodRangeData> ranges = <TimePeriodRangeData>[];
  for (int i = 0; i < starts.length; i += 1) {
    final int start = starts[i];
    final int end = i + 1 < starts.length
        ? starts[i + 1]
        : (start + lastDurationMinutes).clamp(0, 24 * 60);
    ranges.add(TimePeriodRangeData(startMinutes: start, endMinutes: end));
  }
  validateTimeSlotRanges(ranges);
  return List<TimePeriodRangeData>.unmodifiable(ranges);
}
