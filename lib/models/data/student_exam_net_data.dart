class StudentExamNetData {
  const StudentExamNetData({required this.records});

  final List<StudentExamRecordNetData> records;

  factory StudentExamNetData.fromJson(Map<String, dynamic> json) {
    final Object? rawList = json['list'];
    final List<StudentExamRecordNetData> records = rawList is List<dynamic>
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(StudentExamRecordNetData.fromJson)
            .toList()
        : const <StudentExamRecordNetData>[];
    return StudentExamNetData(records: records);
  }
}

class StudentExamRecordNetData {
  const StudentExamRecordNetData({
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

  factory StudentExamRecordNetData.fromJson(Map<String, dynamic> json) {
    return StudentExamRecordNetData(
      termName: _readRequiredString(json['calendar']),
      courseName: _readRequiredString(json['courseName']),
      courseCode: _readRequiredString(json['courseCode']),
      roomName: _readNullableString(json['roomName']),
      examTime: _readNullableString(json['examTime']),
      remark: _readNullableString(json['remark']),
      examSituation: _readNullableInt(json['examSituation']),
    );
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
