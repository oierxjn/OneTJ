import 'package:json_annotation/json_annotation.dart';

part 'grade_net_data.g.dart';

@JsonSerializable(explicitToJson: true)
class GradeNetData {
  final String? totalGradePoint;
  final String? actualCredit;
  final String? failingCredits;
  final String? failingCourseCount;
  final List<GradeTermNetData>? term;

  const GradeNetData({
    this.totalGradePoint,
    this.actualCredit,
    this.failingCredits,
    this.failingCourseCount,
    this.term,
  });

  factory GradeNetData.fromJson(Map<String, dynamic> json) =>
      _$GradeNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$GradeNetDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GradeTermNetData {
  final int? termcode;
  final String? termName;
  final String? calName;
  final String? averagePoint;
  final List<GradeCreditInfoNetData>? creditInfo;

  const GradeTermNetData({
    this.termcode,
    this.termName,
    this.calName,
    this.averagePoint,
    this.creditInfo,
  });

  factory GradeTermNetData.fromJson(Map<String, dynamic> json) =>
      _$GradeTermNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$GradeTermNetDataToJson(this);
}

@JsonSerializable()
class GradeCreditInfoNetData {
  final int? id;
  final String? year;
  final int? term;
  final String? calName;
  final int? calendarId;
  final String? studentId;
  final String? studentName;
  final String? courseNum;
  final String? courseCode;
  final String? courseName;
  final String? scoreName;
  final int? scoreRecordType;
  final int? scoreEaxmType;
  final String? score;
  final int? gradePoint;
  final int? isPass;
  final String? isPassName;
  final String? scoreNatureName;
  final String? scoreEaxmTypeI18n;
  final String? courseNature;
  final String? courseLabel;
  final String? courseLabName;
  final String? courseType;
  final int? credit;
  final String? couresType;
  final String? examMode;
  final String? publicCoursesType;
  final String? publicCoursesName;
  final String? updateTime;
  final String? createdPerson;
  final String? createdTime;
  final String? importUserCode;
  final String? keepField;
  final String? oldData;
  final String? scoreLabel;
  final String? realAgainExamScore;
  final String? teachingClassId;
  final int? scoreSourrce;

  const GradeCreditInfoNetData({
    this.id,
    this.year,
    this.term,
    this.calName,
    this.calendarId,
    this.studentId,
    this.studentName,
    this.courseNum,
    this.courseCode,
    this.courseName,
    this.scoreName,
    this.scoreRecordType,
    this.scoreEaxmType,
    this.score,
    this.gradePoint,
    this.isPass,
    this.isPassName,
    this.scoreNatureName,
    this.scoreEaxmTypeI18n,
    this.courseNature,
    this.courseLabel,
    this.courseLabName,
    this.courseType,
    this.credit,
    this.couresType,
    this.examMode,
    this.publicCoursesType,
    this.publicCoursesName,
    this.updateTime,
    this.createdPerson,
    this.createdTime,
    this.importUserCode,
    this.keepField,
    this.oldData,
    this.scoreLabel,
    this.realAgainExamScore,
    this.teachingClassId,
    this.scoreSourrce,
  });

  factory GradeCreditInfoNetData.fromJson(Map<String, dynamic> json) =>
      _$GradeCreditInfoNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$GradeCreditInfoNetDataToJson(this);
}
