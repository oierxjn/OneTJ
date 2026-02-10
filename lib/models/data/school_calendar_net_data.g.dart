// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_calendar_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolCalendarNetData _$SchoolCalendarNetDataFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'SchoolCalendarNetData',
      json,
      ($checkedConvert) {
        final val = SchoolCalendarNetData(
          schoolCalendar: $checkedConvert(
              'schoolCalendar',
              (v) => SchoolCalendarItemNetData.fromJson(
                  v as Map<String, dynamic>)),
          week: $checkedConvert('week', (v) => (v as num).toInt()),
          simpleName: $checkedConvert('simpleName', (v) => v as String),
          now: $checkedConvert('now', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
        );
        return val;
      },
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
    $checkedCreate(
      'SchoolCalendarItemNetData',
      json,
      ($checkedConvert) {
        final val = SchoolCalendarItemNetData(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          year: $checkedConvert('year', (v) => (v as num).toInt()),
          term: $checkedConvert('term', (v) => (v as num).toInt()),
          beginDay: $checkedConvert('beginDay', (v) => (v as num).toInt()),
          endDay: $checkedConvert('endDay', (v) => (v as num).toInt()),
          weekNum: $checkedConvert('weekNum', (v) => (v as num).toInt()),
          weekBeginDay:
              $checkedConvert('weekBenginDay', (v) => (v as num).toInt()),
          createdAt: $checkedConvert('createdAt', (v) => v as String?),
          updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
          deleteFlag:
              $checkedConvert('deleteFlag', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
      fieldKeyMap: const {'weekBeginDay': 'weekBenginDay'},
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
