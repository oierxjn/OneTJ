import 'package:onetj/models/cet_score_data.dart';

class CetScoreViewRecord {
  const CetScoreViewRecord({
    required this.levelLabel,
    required this.termName,
    required this.score,
    required this.ticketNumber,
    required this.student,
    required this.subjectName,
    required this.oralScore,
  });

  final String levelLabel;
  final String termName;
  final String score;
  final String ticketNumber;
  final String student;
  final String subjectName;
  final String oralScore;

  factory CetScoreViewRecord.fromData(CetScoreRecordData data) {
    final String student = [data.studentId, data.studentName]
        .where((String value) => value.isNotEmpty)
        .join(' ');
    return CetScoreViewRecord(
      levelLabel: switch (data.cetType) {
        '1' => 'CET-4',
        '2' => 'CET-6',
        _ => 'CET',
      },
      termName: _valueOrPlaceholder(data.termName),
      score: _valueOrPlaceholder(data.score),
      ticketNumber: _valueOrPlaceholder(data.ticketNumber),
      student: _valueOrPlaceholder(student),
      subjectName: _valueOrPlaceholder(data.subjectName),
      oralScore: _valueOrPlaceholder(data.oralScore),
    );
  }
}

String _valueOrPlaceholder(String value) {
  return value.isEmpty ? '—' : value;
}
