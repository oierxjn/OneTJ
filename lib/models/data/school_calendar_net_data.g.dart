// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_calendar_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolCalendarNetData _$SchoolCalendarNetDataFromJson(
        Map<String, dynamic> json) =>
    SchoolCalendarNetData(
      schoolCalendar: SchoolCalendarItemNetData.fromJson(
          json['schoolCalendar'] as Map<String, dynamic>),
      week: (json['week'] as num).toInt(),
      simpleName: json['simpleName'] as String,
      now: json['now'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$SchoolCalendarNetDataToJson(
        SchoolCalendarNetData instance) =>
    <String, dynamic>{
      'schoolCalendar': instance.schoolCalendar,
      'week': instance.week,
      'simpleName': instance.simpleName,
      'now': instance.now,
      'name': instance.name,
    };

SchoolCalendarItemNetData _$SchoolCalendarItemNetDataFromJson(
        Map<String, dynamic> json) =>
    SchoolCalendarItemNetData(
      id: (json['id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      term: (json['term'] as num).toInt(),
      beginDay: (json['beginDay'] as num).toInt(),
      endDay: (json['endDay'] as num).toInt(),
      weekNum: (json['weekNum'] as num).toInt(),
      weekBeginDay: (json['weekBenginDay'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deleteFlag: (json['deleteFlag'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SchoolCalendarItemNetDataToJson(
        SchoolCalendarItemNetData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'term': instance.term,
      'beginDay': instance.beginDay,
      'endDay': instance.endDay,
      'weekNum': instance.weekNum,
      'weekBenginDay': instance.weekBeginDay,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deleteFlag': instance.deleteFlag,
    };
