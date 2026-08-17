import 'package:onetj/models/base_data.dart';
import 'package:onetj/models/data/student_exam_net_data.dart';

class StudentExamData extends BaseData {
  const StudentExamData({required this.records});

  final List<StudentExamRecordData> records;

  factory StudentExamData.fromNetData(StudentExamNetData data) {
    return StudentExamData(
      records: data.records.map(StudentExamRecordData.fromNetData).toList(),
    );
  }

  factory StudentExamData.fromJson(Map<String, dynamic> json) {
    final Object? rawRecords = json['records'];
    return StudentExamData(
      records: rawRecords is List<dynamic>
          ? rawRecords
              .whereType<Map<String, dynamic>>()
              .map(StudentExamRecordData.fromJson)
              .toList()
          : const <StudentExamRecordData>[],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'records':
          records.map((StudentExamRecordData item) => item.toJson()).toList(),
    };
  }
}

class StudentExamRecordData {
  const StudentExamRecordData({
    required this.termName,
    required this.courseName,
    required this.courseCode,
    required this.roomName,
    required this.examTime,
    required this.remark,
    required this.examSituation,
  });

  final String termName;
  final String courseName;
  final String courseCode;
  final String? roomName;
  final String? examTime;
  final String? remark;
  final int? examSituation;

  bool get isExam => examSituation == 1 || roomName != null;

  factory StudentExamRecordData.fromNetData(StudentExamRecordNetData data) {
    return StudentExamRecordData(
      termName: data.termName,
      courseName: data.courseName,
      courseCode: data.courseCode,
      roomName: data.roomName,
      examTime: data.examTime,
      remark: data.remark,
      examSituation: data.examSituation,
    );
  }

  factory StudentExamRecordData.fromJson(Map<String, dynamic> json) {
    return StudentExamRecordData(
      termName: _readRequiredString(json['termName']),
      courseName: _readRequiredString(json['courseName']),
      courseCode: _readRequiredString(json['courseCode']),
      roomName: _readNullableString(json['roomName']),
      examTime: _readNullableString(json['examTime']),
      remark: _readNullableString(json['remark']),
      examSituation: _readNullableInt(json['examSituation']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'termName': termName,
      'courseName': courseName,
      'courseCode': courseCode,
      'roomName': roomName,
      'examTime': examTime,
      'remark': remark,
      'examSituation': examSituation,
    };
  }
}

String _readRequiredString(Object? value) => _readNullableString(value) ?? '';

String? _readNullableString(Object? value) {
  final String? result = value?.toString().trim();
  return result == null || result.isEmpty || result == 'null' ? null : result;
}

int? _readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}
