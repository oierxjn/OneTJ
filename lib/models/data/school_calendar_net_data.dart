import 'package:json_annotation/json_annotation.dart';

part 'school_calendar_net_data.g.dart';

@JsonSerializable(checked: true)
class SchoolCalendarNetData {
  final SchoolCalendarItemNetData schoolCalendar;

  final int week;

  final String simpleName;
  final String now;
  final String name;

  const SchoolCalendarNetData({
    required this.schoolCalendar,
    required this.week,
    required this.simpleName,
    required this.now,
    required this.name,
  });

  factory SchoolCalendarNetData.fromJson(Map<String, dynamic> json) =>
      _$SchoolCalendarNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolCalendarNetDataToJson(this);
}

@JsonSerializable(checked: true)
class SchoolCalendarItemNetData {
  final int id;
  final int year;
  final int term;

  /// 毫秒级时间戳
  final int beginDay;
  final int endDay;

  final int weekNum;
  @JsonKey(name: 'weekBenginDay')
  final int weekBeginDay;

  final String? createdAt;
  final String? updatedAt;

  final int? deleteFlag;

  const SchoolCalendarItemNetData({
    required this.id,
    required this.year,
    required this.term,
    required this.beginDay,
    required this.endDay,
    required this.weekNum,
    required this.weekBeginDay,
    required this.createdAt,
    required this.updatedAt,
    required this.deleteFlag,
  });

  factory SchoolCalendarItemNetData.fromJson(Map<String, dynamic> json) =>
      _$SchoolCalendarItemNetDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SchoolCalendarItemNetDataToJson(this);
}
