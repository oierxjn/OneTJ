// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_info_net_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentInfoNetData _$StudentInfoNetDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'StudentInfoNetData',
      json,
      ($checkedConvert) {
        final val = StudentInfoNetData(
          campusCode: $checkedConvert('campusCode', (v) => v as String),
          campusName: $checkedConvert('campusName', (v) => v as String?),
          createTime: $checkedConvert('createTime', (v) => v as String),
          currentGrade:
              $checkedConvert('currentGrade', (v) => (v as num).toInt()),
          deptCode: $checkedConvert('deptCode', (v) => v as String),
          deptName: $checkedConvert('deptName', (v) => v as String),
          enrolDate: $checkedConvert('enrolDate', (v) => v as String),
          expGraduationDate:
              $checkedConvert('expGraduationDate', (v) => v as String),
          isIncumbencyCode:
              $checkedConvert('isIncumbencyCode', (v) => v as String?),
          isIncumbencyName:
              $checkedConvert('isIncumbencyName', (v) => v as String?),
          isMembershipCode:
              $checkedConvert('isMembershipCode', (v) => v as String),
          isMembershipName:
              $checkedConvert('isMembershipName', (v) => v as String),
          isOverseasCode: $checkedConvert('isOverseasCode', (v) => v as String),
          isOverseasName: $checkedConvert('isOverseasName', (v) => v as String),
          leaveSchoolCode:
              $checkedConvert('leaveSchoolCode', (v) => v as String),
          leaveSchoolName:
              $checkedConvert('leaveSchoolName', (v) => v as String),
          lengthSchooling:
              $checkedConvert('lengthSchooling', (v) => v as String),
          managementCollege2Code:
              $checkedConvert('managementCollege2Code', (v) => v as String?),
          managementCollege2Name:
              $checkedConvert('managementCollege2Name', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String),
          offSchool: $checkedConvert('offSchool', (v) => v as String?),
          politicalStatusCode:
              $checkedConvert('politicalStatusCode', (v) => v as String),
          politicalStatusName:
              $checkedConvert('politicalStatusName', (v) => v as String),
          registrationStatusCode:
              $checkedConvert('registrationStatusCode', (v) => v as String),
          registrationStatusName:
              $checkedConvert('registrationStatusName', (v) => v as String),
          schoolCode: $checkedConvert('schoolCode', (v) => v as String),
          schoolName: $checkedConvert('schoolName', (v) => v as String),
          secondDeptCode: $checkedConvert('secondDeptCode', (v) => v as String),
          secondDeptName: $checkedConvert('secondDeptName', (v) => v as String),
          sexCode: $checkedConvert('sexCode', (v) => v as String),
          sexName: $checkedConvert('sexName', (v) => v as String),
          statusCode: $checkedConvert('statusCode', (v) => v as String),
          statusName: $checkedConvert('statusName', (v) => v as String),
          teacherId: $checkedConvert('teacherId', (v) => v as String),
          trainingCategoryCode:
              $checkedConvert('trainingCategoryCode', (v) => v as String),
          trainingCategoryName:
              $checkedConvert('trainingCategoryName', (v) => v as String),
          trainingLevelCode:
              $checkedConvert('trainingLevelCode', (v) => v as String),
          trainingLevelName:
              $checkedConvert('trainingLevelName', (v) => v as String),
          updateTime: $checkedConvert('updateTime', (v) => v as String),
          userId: $checkedConvert('userId', (v) => v as String),
          userTypeCode: $checkedConvert('userTypeCode', (v) => v as String),
          userTypeName: $checkedConvert('userTypeName', (v) => v as String),
          viceTeacherId: $checkedConvert('viceTeacherId', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$StudentInfoNetDataToJson(StudentInfoNetData instance) =>
    <String, dynamic>{
      'campusCode': instance.campusCode,
      'campusName': instance.campusName,
      'createTime': instance.createTime,
      'currentGrade': instance.currentGrade,
      'deptCode': instance.deptCode,
      'deptName': instance.deptName,
      'enrolDate': instance.enrolDate,
      'expGraduationDate': instance.expGraduationDate,
      'isIncumbencyCode': instance.isIncumbencyCode,
      'isIncumbencyName': instance.isIncumbencyName,
      'isMembershipCode': instance.isMembershipCode,
      'isMembershipName': instance.isMembershipName,
      'isOverseasCode': instance.isOverseasCode,
      'isOverseasName': instance.isOverseasName,
      'leaveSchoolCode': instance.leaveSchoolCode,
      'leaveSchoolName': instance.leaveSchoolName,
      'lengthSchooling': instance.lengthSchooling,
      'managementCollege2Code': instance.managementCollege2Code,
      'managementCollege2Name': instance.managementCollege2Name,
      'name': instance.name,
      'offSchool': instance.offSchool,
      'politicalStatusCode': instance.politicalStatusCode,
      'politicalStatusName': instance.politicalStatusName,
      'registrationStatusCode': instance.registrationStatusCode,
      'registrationStatusName': instance.registrationStatusName,
      'schoolCode': instance.schoolCode,
      'schoolName': instance.schoolName,
      'secondDeptCode': instance.secondDeptCode,
      'secondDeptName': instance.secondDeptName,
      'sexCode': instance.sexCode,
      'sexName': instance.sexName,
      'statusCode': instance.statusCode,
      'statusName': instance.statusName,
      'teacherId': instance.teacherId,
      'trainingCategoryCode': instance.trainingCategoryCode,
      'trainingCategoryName': instance.trainingCategoryName,
      'trainingLevelCode': instance.trainingLevelCode,
      'trainingLevelName': instance.trainingLevelName,
      'updateTime': instance.updateTime,
      'userId': instance.userId,
      'userTypeCode': instance.userTypeCode,
      'userTypeName': instance.userTypeName,
      'viceTeacherId': instance.viceTeacherId,
    };
