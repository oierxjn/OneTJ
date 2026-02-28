import 'package:onetj/models/time_period_range.dart';

const int kDefaultMaxWeek = 22;

const int kLegacyTimeSlotLastDurationMinutes = 45;

const List<int> kDefaultTimeSlotStartMinutes = [
  8 * 60,
  8 * 60 + 50,
  10 * 60,
  10 * 60 + 50,
  13 * 60 + 30,
  14 * 60 + 20,
  15 * 60 + 30,
  16 * 60 + 20,
  18 * 60 + 30,
  19 * 60 + 20,
  20 * 60 + 10,
];

const List<int> kDefaultTimeSlotEndMinutes = [
  8 * 60 + 50,
  10 * 60,
  10 * 60 + 50,
  13 * 60 + 30,
  14 * 60 + 20,
  15 * 60 + 30,
  16 * 60 + 20,
  18 * 60 + 30,
  19 * 60 + 20,
  20 * 60 + 10,
  20 * 60 + 55,
];

final List<TimePeriodRangeData> kDefaultTimeSlotRanges =
    _buildDefaultTimeSlotRanges();

List<TimePeriodRangeData> _buildDefaultTimeSlotRanges() {
  final int count = kDefaultTimeSlotStartMinutes.length;
  if (count != kDefaultTimeSlotEndMinutes.length) {
    throw StateError('Default time slot start/end length mismatch');
  }
  return List<TimePeriodRangeData>.unmodifiable(
    List<TimePeriodRangeData>.generate(
      count,
      (int index) => TimePeriodRangeData(
        startMinutes: kDefaultTimeSlotStartMinutes[index],
        endMinutes: kDefaultTimeSlotEndMinutes[index],
      ),
      growable: false,
    ),
  );
}
