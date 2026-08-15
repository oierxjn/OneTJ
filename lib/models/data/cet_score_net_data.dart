class CetScoreNetData {
  const CetScoreNetData({required this.records});

  final List<CetScoreRecordNetData> records;

  factory CetScoreNetData.fromJson(Map<String, dynamic> json) {
    final Object? rawList = json['list'];
    final List<CetScoreRecordNetData> records = rawList is List<dynamic>
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(CetScoreRecordNetData.fromJson)
            .toList()
        : const <CetScoreRecordNetData>[];
    return CetScoreNetData(records: records);
  }
}

class CetScoreRecordNetData {
  const CetScoreRecordNetData({
    required this.cetType,
    required this.termName,
    required this.score,
    required this.ticketNumber,
    required this.studentName,
    required this.studentId,
    required this.subjectName,
    required this.oralScore,
  });

  final String cetType;
  final String termName;
  final String score;
  final String ticketNumber;
  final String studentName;
  final String studentId;
  final String subjectName;
  final String oralScore;

  factory CetScoreRecordNetData.fromJson(Map<String, dynamic> json) {
    return CetScoreRecordNetData(
      cetType: _readString(json['cetType']),
      termName: _readString(json['calendarYearTermCn']),
      score: _readString(json['score']),
      ticketNumber: _readString(json['cardNo']),
      studentName: _readString(json['studentName']),
      studentId: _readString(json['studentId']),
      subjectName: _readString(json['writtenSubjectName']),
      oralScore: _readString(json['oralScore']),
    );
  }
}

String _readString(Object? value) {
  if (value == null || value == 'null') {
    return '';
  }
  return value.toString();
}
