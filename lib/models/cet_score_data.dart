import 'package:onetj/models/base_data.dart';
import 'package:onetj/models/data/cet_score_net_data.dart';

class CetScoreData extends BaseData {
  const CetScoreData({required this.records});

  final List<CetScoreRecordData> records;

  factory CetScoreData.fromNetData(CetScoreNetData data) {
    return CetScoreData(
      records: data.records.map(CetScoreRecordData.fromNetData).toList(),
    );
  }

  factory CetScoreData.fromJson(Map<String, dynamic> json) {
    final Object? rawRecords = json['records'];
    return CetScoreData(
      records: rawRecords is List<dynamic>
          ? rawRecords
              .whereType<Map<String, dynamic>>()
              .map(CetScoreRecordData.fromJson)
              .toList()
          : const <CetScoreRecordData>[],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'records':
          records.map((CetScoreRecordData item) => item.toJson()).toList(),
    };
  }
}

class CetScoreRecordData {
  const CetScoreRecordData({
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

  factory CetScoreRecordData.fromNetData(CetScoreRecordNetData data) {
    return CetScoreRecordData(
      cetType: data.cetType,
      termName: data.termName,
      score: data.score,
      ticketNumber: data.ticketNumber,
      studentName: data.studentName,
      studentId: data.studentId,
      subjectName: data.subjectName,
      oralScore: data.oralScore,
    );
  }

  factory CetScoreRecordData.fromJson(Map<String, dynamic> json) {
    return CetScoreRecordData(
      cetType: _readString(json['cetType']),
      termName: _readString(json['termName']),
      score: _readString(json['score']),
      ticketNumber: _readString(json['ticketNumber']),
      studentName: _readString(json['studentName']),
      studentId: _readString(json['studentId']),
      subjectName: _readString(json['subjectName']),
      oralScore: _readString(json['oralScore']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cetType': cetType,
      'termName': termName,
      'score': score,
      'ticketNumber': ticketNumber,
      'studentName': studentName,
      'studentId': studentId,
      'subjectName': subjectName,
      'oralScore': oralScore,
    };
  }
}

String _readString(Object? value) {
  if (value == null || value == 'null') {
    return '';
  }
  return value.toString();
}
