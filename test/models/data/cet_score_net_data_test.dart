import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/data/cet_score_net_data.dart';

void main() {
  test('maps the CET API list and normalizes nullable fields', () {
    final CetScoreNetData data = CetScoreNetData.fromJson(
      <String, dynamic>{
        'list': <Map<String, dynamic>>[
          <String, dynamic>{
            'cetType': 1,
            'calendarYearTermCn': '2025年12月',
            'score': 520,
            'cardNo': '123456',
            'studentName': '张三',
            'studentId': '12345678',
            'writtenSubjectName': '大学英语四级',
            'oralScore': null,
          },
        ],
      },
    );

    final CetScoreRecordNetData record = data.records.single;
    expect(record.cetType, '1');
    expect(record.termName, '2025年12月');
    expect(record.score, '520');
    expect(record.ticketNumber, '123456');
    expect(record.studentName, '张三');
    expect(record.studentId, '12345678');
    expect(record.subjectName, '大学英语四级');
    expect(record.oralScore, isEmpty);
  });
}
