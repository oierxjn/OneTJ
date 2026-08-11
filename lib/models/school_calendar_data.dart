import 'package:onetj/models/base_data.dart';
import 'package:onetj/models/data/school_calendar_net_data.dart';

class SchoolCalendarItemData {
  const SchoolCalendarItemData({
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

  final int id;
  final int year;
  final int term;
  final int beginDay;
  final int endDay;
  final int weekNum;
  final int weekBeginDay;
  final String? createdAt;
  final String? updatedAt;
  final int? deleteFlag;

  factory SchoolCalendarItemData.fromNetData(SchoolCalendarItemNetData data) {
    return SchoolCalendarItemData(
      id: data.id,
      year: data.year,
      term: data.term,
      beginDay: data.beginDay,
      endDay: data.endDay,
      weekNum: data.weekNum,
      weekBeginDay: data.weekBeginDay,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deleteFlag: data.deleteFlag,
    );
  }

  factory SchoolCalendarItemData.fromJson(Map<String, dynamic> json) {
    return SchoolCalendarItemData(
      id: json['id'] as int,
      year: json['year'] as int,
      term: json['term'] as int,
      beginDay: json['beginDay'] as int,
      endDay: json['endDay'] as int,
      weekNum: json['weekNum'] as int,
      weekBeginDay: json['weekBeginDay'] as int,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deleteFlag: json['deleteFlag'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'term': term,
      'beginDay': beginDay,
      'endDay': endDay,
      'weekNum': weekNum,
      'weekBeginDay': weekBeginDay,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deleteFlag': deleteFlag,
    };
  }
}

class SchoolCalendarData extends BaseData {
  const SchoolCalendarData({
    required this.schoolCalendar,
    required this.week,
    required this.simpleName,
    required this.now,
    required this.name,
  });

  final SchoolCalendarItemData schoolCalendar;
  final int week;
  final String simpleName;
  final String now;
  final String name;

  factory SchoolCalendarData.fromNetData(SchoolCalendarNetData data) {
    return SchoolCalendarData(
      schoolCalendar: SchoolCalendarItemData.fromNetData(data.schoolCalendar),
      week: data.week,
      simpleName: data.simpleName,
      now: data.now,
      name: data.name,
    );
  }

  factory SchoolCalendarData.fromJson(Map<String, dynamic> json) {
    return SchoolCalendarData(
      schoolCalendar: SchoolCalendarItemData.fromJson(
        json['schoolCalendar'] as Map<String, dynamic>,
      ),
      week: json['week'] as int,
      simpleName: json['simpleName'] as String,
      now: json['now'] as String,
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'schoolCalendar': schoolCalendar.toJson(),
      'week': week,
      'simpleName': simpleName,
      'now': now,
      'name': name,
    };
  }
}
