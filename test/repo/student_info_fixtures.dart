import 'package:onetj/models/student_info_data.dart';

/// [StudentInfoData] 的测试夹具。
///
/// 单独成文件，供 `student_info_repository_test.dart` 与
/// `base_cached_repository_test.dart` 共用——后者需要一个真实仓
/// 库的完整数据来驱动 `_saveCache`，但不便反过来 import 前者的
/// `_test.dart`（那会把对方的 `main` 与测试注册一并引入）。
StudentInfoData buildStudentInfo({String deptName = 'Computer Science'}) {
  return StudentInfoData(
    campusCode: '01',
    campusName: 'Main Campus',
    createTime: '2026-01-01 00:00:00',
    currentGrade: 2022,
    deptCode: 'CS',
    deptName: deptName,
    enrolDate: '2022-09-01',
    expGraduationDate: '2026-06-30',
    isIncumbencyCode: null,
    isIncumbencyName: null,
    isMembershipCode: '0',
    isMembershipName: 'No',
    isOverseasCode: '0',
    isOverseasName: 'No',
    leaveSchoolCode: '0',
    leaveSchoolName: 'In School',
    lengthSchooling: '4',
    managementCollege2Code: null,
    managementCollege2Name: null,
    name: 'Test User',
    offSchool: null,
    politicalStatusCode: '01',
    politicalStatusName: '群众',
    registrationStatusCode: '1',
    registrationStatusName: 'Registered',
    schoolCode: 'SDU',
    schoolName: 'Shandong University',
    secondDeptCode: 'CS',
    secondDeptName: 'Computer Science',
    sexCode: '1',
    sexName: 'Male',
    statusCode: '1',
    statusName: 'Normal',
    teacherId: 'T001',
    trainingCategoryCode: 'A',
    trainingCategoryName: 'General',
    trainingLevelCode: 'UG',
    trainingLevelName: 'Undergraduate',
    updateTime: '2026-01-01 00:00:00',
    userId: 'U001',
    userTypeCode: 'STU',
    userTypeName: 'Student',
    viceTeacherId: null,
  );
}
