import 'package:onetj/app/exception/app_exception.dart';

class TimePeriodRangeData {
  const TimePeriodRangeData({
    required this.startMinutes,
    required this.endMinutes,
  });

  final int startMinutes;
  final int endMinutes;

  factory TimePeriodRangeData.fromJson(Map<String, dynamic> json) {
    final Object? start = json['startMinutes'];
    final Object? end = json['endMinutes'];
    if (start is! int) {
      throw SettingsResolveException(
        message: 'timeSlotRanges.startMinutes must be int',
      );
    }
    if (end is! int) {
      throw SettingsResolveException(
        message: 'timeSlotRanges.endMinutes must be int',
      );
    }
    return TimePeriodRangeData(
      startMinutes: start,
      endMinutes: end,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
    };
  }
}
