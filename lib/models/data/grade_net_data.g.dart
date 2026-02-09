// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeNetData _$GradeNetDataFromJson(Map<String, dynamic> json) => GradeNetData(
      totalGradePoint: json['totalGradePoint'] as String?,
      actualCredit: json['actualCredit'] as String?,
      failingCredits: json['failingCredits'] as String?,
      failingCourseCount: json['failingCourseCount'] as String?,
      term: (json['term'] as List<dynamic>?)
          ?.map((e) => GradeTermNetData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradeNetDataToJson(GradeNetData instance) =>
    <String, dynamic>{
      'totalGradePoint': instance.totalGradePoint,
      'actualCredit': instance.actualCredit,
      'failingCredits': instance.failingCredits,
      'failingCourseCount': instance.failingCourseCount,
      'term': instance.term?.map((e) => e.toJson()).toList(),
    };

GradeTermNetData _$GradeTermNetDataFromJson(Map<String, dynamic> json) =>
    GradeTermNetData(
      termcode: (json['termcode'] as num?)?.toInt(),
      termName: json['termName'] as String?,
      calName: json['calName'] as String?,
      averagePoint: json['averagePoint'] as String?,
      creditInfo: (json['creditInfo'] as List<dynamic>?)
          ?.map(
              (e) => GradeCreditInfoNetData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradeTermNetDataToJson(GradeTermNetData instance) =>
    <String, dynamic>{
      'termcode': instance.termcode,
      'termName': instance.termName,
      'calName': instance.calName,
      'averagePoint': instance.averagePoint,
      'creditInfo': instance.creditInfo?.map((e) => e.toJson()).toList(),
    };

GradeCreditInfoNetData _$GradeCreditInfoNetDataFromJson(
        Map<String, dynamic> json) =>
    GradeCreditInfoNetData(
      id: (json['id'] as num?)?.toInt(),
      year: json['year'] as String?,
      term: (json['term'] as num?)?.toInt(),
      calName: json['calName'] as String?,
      calendarId: (json['calendarId'] as num?)?.toInt(),
      studentId: json['studentId'] as String?,
      studentName: json['studentName'] as String?,
      courseNum: json['courseNum'] as String?,
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      scoreName: json['scoreName'] as String?,
      scoreRecordType: (json['scoreRecordType'] as num?)?.toInt(),
      scoreEaxmType: (json['scoreEaxmType'] as num?)?.toInt(),
      score: json['score'] as String?,
      gradePoint: (json['gradePoint'] as num?)?.toInt(),
      isPass: (json['isPass'] as num?)?.toInt(),
      isPassName: json['isPassName'] as String?,
      scoreNatureName: json['scoreNatureName'] as String?,
      scoreEaxmTypeI18n: json['scoreEaxmTypeI18n'] as String?,
      courseNature: json['courseNature'] as String?,
      courseLabel: json['courseLabel'] as String?,
      courseLabName: json['courseLabName'] as String?,
      courseType: json['courseType'] as String?,
      credit: (json['credit'] as num?)?.toInt(),
      couresType: json['couresType'] as String?,
      examMode: json['examMode'] as String?,
      publicCoursesType: json['publicCoursesType'] as String?,
      publicCoursesName: json['publicCoursesName'] as String?,
      updateTime: json['updateTime'] as String?,
      createdPerson: json['createdPerson'] as String?,
      createdTime: json['createdTime'] as String?,
      importUserCode: json['importUserCode'] as String?,
      keepField: json['keepField'] as String?,
      oldData: json['oldData'] as String?,
      scoreLabel: json['scoreLabel'] as String?,
      realAgainExamScore: json['realAgainExamScore'] as String?,
      teachingClassId: json['teachingClassId'] as String?,
      scoreSourrce: (json['scoreSourrce'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GradeCreditInfoNetDataToJson(
        GradeCreditInfoNetData instance) =>
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
      'scoreEaxmType': instance.scoreEaxmType,
      'score': instance.score,
      'gradePoint': instance.gradePoint,
      'isPass': instance.isPass,
      'isPassName': instance.isPassName,
      'scoreNatureName': instance.scoreNatureName,
      'scoreEaxmTypeI18n': instance.scoreEaxmTypeI18n,
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
