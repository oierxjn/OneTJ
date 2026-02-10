// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'undergraduate_score_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UndergraduateScoreNetData _$UndergraduateScoreNetDataFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UndergraduateScoreNetData',
      json,
      ($checkedConvert) {
        final val = UndergraduateScoreNetData(
          totalGradePoint:
              $checkedConvert('totalGradePoint', (v) => v as String?),
          actualCredit: $checkedConvert('actualCredit', (v) => v as String?),
          failingCredits:
              $checkedConvert('failingCredits', (v) => v as String?),
          failingCourseCount:
              $checkedConvert('failingCourseCount', (v) => v as String?),
          term: $checkedConvert(
              'term',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => UndergraduateScoreTermNetData.fromJson(
                      e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$UndergraduateScoreNetDataToJson(
        UndergraduateScoreNetData instance) =>
    <String, dynamic>{
      'totalGradePoint': instance.totalGradePoint,
      'actualCredit': instance.actualCredit,
      'failingCredits': instance.failingCredits,
      'failingCourseCount': instance.failingCourseCount,
      'term': instance.term?.map((e) => e.toJson()).toList(),
    };

UndergraduateScoreTermNetData _$UndergraduateScoreTermNetDataFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'UndergraduateScoreTermNetData',
      json,
      ($checkedConvert) {
        final val = UndergraduateScoreTermNetData(
          termcode: $checkedConvert('termcode', (v) => v as String?),
          termName: $checkedConvert('termName', (v) => v as String?),
          calName: $checkedConvert('calName', (v) => v as String?),
          averagePoint: $checkedConvert('averagePoint', (v) => v as String?),
          creditInfo: $checkedConvert(
              'creditInfo',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => UndergraduateScoreCreditInfoNetData.fromJson(
                      e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$UndergraduateScoreTermNetDataToJson(
        UndergraduateScoreTermNetData instance) =>
    <String, dynamic>{
      'termcode': instance.termcode,
      'termName': instance.termName,
      'calName': instance.calName,
      'averagePoint': instance.averagePoint,
      'creditInfo': instance.creditInfo?.map((e) => e.toJson()).toList(),
    };

UndergraduateScoreCreditInfoNetData
    _$UndergraduateScoreCreditInfoNetDataFromJson(Map<String, dynamic> json) =>
        $checkedCreate(
          'UndergraduateScoreCreditInfoNetData',
          json,
          ($checkedConvert) {
            final val = UndergraduateScoreCreditInfoNetData(
              id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
              year: $checkedConvert('year', (v) => v as String?),
              term: $checkedConvert('term', (v) => (v as num?)?.toInt()),
              calName: $checkedConvert('calName', (v) => v as String?),
              calendarId:
                  $checkedConvert('calendarId', (v) => (v as num?)?.toInt()),
              studentId: $checkedConvert('studentId', (v) => v as String?),
              studentName: $checkedConvert('studentName', (v) => v as String?),
              courseNum: $checkedConvert('courseNum', (v) => v as String?),
              courseCode: $checkedConvert('courseCode', (v) => v as String?),
              courseName: $checkedConvert('courseName', (v) => v as String?),
              scoreName: $checkedConvert('scoreName', (v) => v as String?),
              scoreRecordType: $checkedConvert(
                  'scoreRecordType', (v) => (v as num?)?.toInt()),
              scoreExamType: $checkedConvert(
                'scoreExamType',
                (v) => (v as num?)?.toInt(),
                readValue: _readScoreExamType,
              ),
              score: $checkedConvert('score', (v) => v as String?),
              gradePoint:
                  $checkedConvert('gradePoint', (v) => (v as num?)?.toInt()),
              isPass: $checkedConvert('isPass', (v) => (v as num?)?.toInt()),
              isPassName: $checkedConvert('isPassName', (v) => v as String?),
              scoreNatureName:
                  $checkedConvert('scoreNatureName', (v) => v as String?),
              scoreExamTypeI18n: $checkedConvert(
                'scoreExamTypeI18n',
                (v) => v as String?,
                readValue: _readScoreExamTypeI18n,
              ),
              courseNature:
                  $checkedConvert('courseNature', (v) => v as String?),
              courseLabel: $checkedConvert('courseLabel', (v) => v as String?),
              courseLabName:
                  $checkedConvert('courseLabName', (v) => v as String?),
              courseType: $checkedConvert('courseType', (v) => v as String?),
              credit: $checkedConvert('credit', (v) => (v as num?)?.toInt()),
              couresType: $checkedConvert('couresType', (v) => v as String?),
              examMode: $checkedConvert('examMode', (v) => v as String?),
              publicCoursesType:
                  $checkedConvert('publicCoursesType', (v) => v as String?),
              publicCoursesName:
                  $checkedConvert('publicCoursesName', (v) => v as String?),
              updateTime: $checkedConvert('updateTime', (v) => v as String?),
              createdPerson:
                  $checkedConvert('createdPerson', (v) => v as String?),
              createdTime: $checkedConvert('createdTime', (v) => v as String?),
              importUserCode:
                  $checkedConvert('importUserCode', (v) => v as String?),
              keepField: $checkedConvert('keepField', (v) => v as String?),
              oldData: $checkedConvert('oldData', (v) => (v as num?)?.toInt()),
              scoreLabel: $checkedConvert('scoreLabel', (v) => v as String?),
              realAgainExamScore:
                  $checkedConvert('realAgainExamScore', (v) => v as String?),
              teachingClassId:
                  $checkedConvert('teachingClassId', (v) => v as String?),
              scoreSourrce:
                  $checkedConvert('scoreSourrce', (v) => (v as num?)?.toInt()),
            );
            return val;
          },
        );

Map<String, dynamic> _$UndergraduateScoreCreditInfoNetDataToJson(
        UndergraduateScoreCreditInfoNetData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'term': instance.term,
      'calName': instance.calName,
      'calendarId': instance.calendarId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'courseNum': instance.courseNum,
      'courseCode': instance.courseCode,
      'courseName': instance.courseName,
      'scoreName': instance.scoreName,
      'scoreRecordType': instance.scoreRecordType,
      'scoreExamType': instance.scoreExamType,
      'score': instance.score,
      'gradePoint': instance.gradePoint,
      'isPass': instance.isPass,
      'isPassName': instance.isPassName,
      'scoreNatureName': instance.scoreNatureName,
      'scoreExamTypeI18n': instance.scoreExamTypeI18n,
      'courseNature': instance.courseNature,
      'courseLabel': instance.courseLabel,
      'courseLabName': instance.courseLabName,
      'courseType': instance.courseType,
      'credit': instance.credit,
      'couresType': instance.couresType,
      'examMode': instance.examMode,
      'publicCoursesType': instance.publicCoursesType,
      'publicCoursesName': instance.publicCoursesName,
      'updateTime': instance.updateTime,
      'createdPerson': instance.createdPerson,
      'createdTime': instance.createdTime,
      'importUserCode': instance.importUserCode,
      'keepField': instance.keepField,
      'oldData': instance.oldData,
      'scoreLabel': instance.scoreLabel,
      'realAgainExamScore': instance.realAgainExamScore,
      'teachingClassId': instance.teachingClassId,
      'scoreSourrce': instance.scoreSourrce,
    };
