import 'dart:convert';

/// 弗兰克-赫兹实验草稿中的单行测量数据。
class FranckHertzDraftRow {
  const FranckHertzDraftRow({
    required this.vg2kText,
    required this.ipText,
  });

  final String vg2kText;
  final String ipText;

  factory FranckHertzDraftRow.fromJson(Map<String, dynamic> json) {
    return FranckHertzDraftRow(
      vg2kText: json['vg2kText'] as String? ?? '',
      ipText: json['ipText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vg2kText': vg2kText,
        'ipText': ipText,
      };
}

/// 弗兰克-赫兹实验的持久化草稿。
///
/// 只保存原始输入文本，分析结果由 [FranckHertzViewModel] 在加载后重算。
class FranckHertzDraft {
  const FranckHertzDraft({
    required this.vfText,
    required this.vg1kText,
    required this.vg2aText,
    required this.referenceVoltageText,
    required this.rows,
  });

  final String vfText;
  final String vg1kText;
  final String vg2aText;
  final String referenceVoltageText;
  final List<FranckHertzDraftRow> rows;

  factory FranckHertzDraft.fromJson(Map<String, dynamic> json) {
    final dynamic rawRows = json['rows'];
    final List<FranckHertzDraftRow> rows = rawRows is List
        ? rawRows
            .map(
              (dynamic element) => FranckHertzDraftRow.fromJson(
                element as Map<String, dynamic>,
              ),
            )
            .toList(growable: false)
        : <FranckHertzDraftRow>[];
    return FranckHertzDraft(
      vfText: json['vfText'] as String? ?? '',
      vg1kText: json['vg1kText'] as String? ?? '',
      vg2aText: json['vg2aText'] as String? ?? '',
      referenceVoltageText: json['referenceVoltageText'] as String? ?? '',
      rows: rows,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'vfText': vfText,
        'vg1kText': vg1kText,
        'vg2aText': vg2aText,
        'referenceVoltageText': referenceVoltageText,
        'rows': rows
            .map((FranckHertzDraftRow row) => row.toJson())
            .toList(growable: false),
      };

  factory FranckHertzDraft.fromJsonString(String jsonString) {
    return FranckHertzDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}