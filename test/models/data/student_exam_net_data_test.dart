import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/models/data/student_exam_net_data.dart';

void main() {
  test('maps exam records and normalizes optional string fields', () {
    final StudentExamNetData data = StudentExamNetData.fromJson(
      <String, dynamic>{
        'list': <Map<String, dynamic>>[
          <String, dynamic>{
            'calendar': '2026-2027学年第一学期',
            'courseName': '高等数学',
            'courseCode': 123456,
            'roomName': '四平路校区-南楼101',
            'examTime': '2026-12-30 08:00-10:00',
            'remark': '闭卷考试',
            'examSituation': 1,
          },
          <String, dynamic>{
            'calendar': '2026-2027学年第一学期',
            'courseName': '大学生心理健康',
            'courseCode': 'PSY1001',
            'roomName': 'null',
            'examTime': null,
            'remark': null,
            'examSituation': 0,
          },
        ],
      },
    );

    expect(data.records, hasLength(2));
    expect(data.records.first.termName, '2026-2027学年第一学期');
    expect(data.records.first.courseCode, '123456');
    expect(data.records.first.roomName, '四平路校区-南楼101');
    expect(data.records.first.isExam, isTrue);
    expect(data.records.last.roomName, isNull);
    expect(data.records.last.examTime, isNull);
    expect(data.records.last.remark, isNull);
    expect(data.records.last.isExam, isFalse);
  });

  test('returns an empty record list for a malformed response', () {
    expect(
      StudentExamNetData.fromJson(<String, dynamic>{'list': 'not-a-list'})
          .records,
      isEmpty,
    );
  });
}
