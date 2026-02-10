import 'package:json_annotation/json_annotation.dart';

part 'undergraduate_score_net_data.g.dart';

@JsonSerializable(explicitToJson: true, checked: true)
class UndergraduateScoreNetData {
  final String? totalGradePoint;
  final String? actualCredit;
  final String? failingCredits;
  final String? failingCourseCount;
  final List<UndergraduateScoreTermNetData>? term;

  const UndergraduateScoreNetData({
    this.totalGradePoint,
    this.actualCredit,
    this.failingCredits,
    this.failingCourseCount,
    this.term,
  });

  factory UndergraduateScoreNetData.fromJson(Map<String, dynamic> json) =>
      _$UndergraduateScoreNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$UndergraduateScoreNetDataToJson(this);
}

@JsonSerializable(explicitToJson: true, checked: true)
class UndergraduateScoreTermNetData {
  @JsonKey(fromJson: _termcodeFromJson)
  final String? termcode;
  final String? termName;
  final String? calName;
  final String? averagePoint;
  final List<UndergraduateScoreCreditInfoNetData>? creditInfo;

  const UndergraduateScoreTermNetData({
    this.termcode,
    this.termName,
    this.calName,
    this.averagePoint,
    this.creditInfo,
  });

  factory UndergraduateScoreTermNetData.fromJson(Map<String, dynamic> json) =>
      _$UndergraduateScoreTermNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$UndergraduateScoreTermNetDataToJson(this);
}

@JsonSerializable(checked: true)
class UndergraduateScoreCreditInfoNetData {
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
  @JsonKey(readValue: _readScoreExamType)
  final int? scoreExamType;
  final String? score;
  final int? gradePoint;
  final int? isPass;
  final String? isPassName;
  final String? scoreNatureName;
  @JsonKey(readValue: _readScoreExamTypeI18n)
  final String? scoreExamTypeI18n;
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
  final int? oldData;
  final String? scoreLabel;
  final String? realAgainExamScore;
  final String? teachingClassId;
  final int? scoreSourrce;

  const UndergraduateScoreCreditInfoNetData({
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
    this.scoreExamType,
    this.score,
    this.gradePoint,
    this.isPass,
    this.isPassName,
    this.scoreNatureName,
    this.scoreExamTypeI18n,
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

  factory UndergraduateScoreCreditInfoNetData.fromJson(Map<String, dynamic> json) =>
      _$UndergraduateScoreCreditInfoNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$UndergraduateScoreCreditInfoNetDataToJson(this);
}

Object? _readScoreExamType(Map json, String key) =>
    json['scoreExamType'] ?? json['scoreEaxmType'];

Object? _readScoreExamTypeI18n(Map json, String key) =>
    json['scoreExamTypeI18n'] ?? json['scoreEaxmTypeI18n'];

String? _termcodeFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  if (value is int) {
    return value.toString();
  }
  if (value is num) {
    return value.toString();
  }
  throw FormatException('Invalid termcode type: ${value.runtimeType}');
}
