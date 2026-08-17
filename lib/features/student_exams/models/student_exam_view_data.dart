import 'package:onetj/models/student_exam_data.dart';

class StudentExamViewRecord {
  const StudentExamViewRecord({
    required this.termName,
    required this.courseName,
    required this.courseCode,
    required this.roomName,
    required this.examTime,
    required this.remark,
    required this.isExam,
  });

  final String termName;
  final String courseName;
  final String courseCode;
  final String? roomName;
  final String? examTime;
  final String? remark;
  final bool isExam;

  factory StudentExamViewRecord.fromData(StudentExamRecordData data) {
    return StudentExamViewRecord(
      termName: data.termName,
      courseName: data.courseName,
      courseCode: data.courseCode,
      roomName: data.roomName,
      examTime: data.examTime,
      remark: data.remark,
      isExam: data.isExam,
    );
  }

  static int compare(
    StudentExamViewRecord left,
    StudentExamViewRecord right,
  ) {
    if (left.isExam != right.isExam) {
      return left.isExam ? -1 : 1;
    }
    final int timeOrder = (left.examTime ?? '').compareTo(right.examTime ?? '');
    if (timeOrder != 0) {
      return timeOrder;
    }
    return left.courseName.compareTo(right.courseName);
  }
}
