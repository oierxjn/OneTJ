import 'package:json_annotation/json_annotation.dart';

part 'student_info_net_data.g.dart';

@JsonSerializable(checked: true)
class StudentInfoNetData {
  final String campusCode;
  final String? campusName;

  /// 创建时间
  final String createTime;
  /// 当前年级
  final int currentGrade;
  final String deptCode;
  final String deptName;

  final String enrolDate;
  final String expGraduationDate;

  final String? isIncumbencyCode;
  final String? isIncumbencyName;

  final String isMembershipCode;
  final String isMembershipName;

  final String isOverseasCode;
  final String isOverseasName;

  final String leaveSchoolCode;
  final String leaveSchoolName;

  final String lengthSchooling;

  final String? managementCollege2Code;
  final String? managementCollege2Name;

  final String name;

  final String? offSchool;

  final String politicalStatusCode;
  final String politicalStatusName;

  final String registrationStatusCode;
  final String registrationStatusName;

  final String schoolCode;
  final String schoolName;

  final String secondDeptCode;
  final String secondDeptName;

  final String sexCode;
  final String sexName;

  final String statusCode;
  final String statusName;

  final String teacherId;

  final String trainingCategoryCode;
  final String trainingCategoryName;

  final String trainingLevelCode;
  final String trainingLevelName;

  final String updateTime;

  final String userId;

  final String userTypeCode;
  final String userTypeName;

  final String? viceTeacherId;

  const StudentInfoNetData({
    required this.campusCode,
    this.campusName,
    required this.createTime,
    required this.currentGrade,
    required this.deptCode,
    required this.deptName,
    required this.enrolDate,
    required this.expGraduationDate,
    this.isIncumbencyCode,
    this.isIncumbencyName,
    required this.isMembershipCode,
    required this.isMembershipName,
    required this.isOverseasCode,
    required this.isOverseasName,
    required this.leaveSchoolCode,
    required this.leaveSchoolName,
    required this.lengthSchooling,
    this.managementCollege2Code,
    this.managementCollege2Name,
    required this.name,
    this.offSchool,
    required this.politicalStatusCode,
    required this.politicalStatusName,
    required this.registrationStatusCode,
    required this.registrationStatusName,
    required this.schoolCode,
    required this.schoolName,
    required this.secondDeptCode,
    required this.secondDeptName,
    required this.sexCode,
    required this.sexName,
    required this.statusCode,
    required this.statusName,
    required this.teacherId,
    required this.trainingCategoryCode,
    required this.trainingCategoryName,
    required this.trainingLevelCode,
    required this.trainingLevelName,
    required this.updateTime,
    required this.userId,
    required this.userTypeCode,
    required this.userTypeName,
    this.viceTeacherId,
  });

  factory StudentInfoNetData.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoNetDataFromJson(json);

  Map<String, dynamic> toJson() => _$StudentInfoNetDataToJson(this);
}
