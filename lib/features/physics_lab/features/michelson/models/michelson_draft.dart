import 'dart:convert';

/// 迈克尔逊干涉实验的持久化草稿。
///
/// 只保存原始输入文本，派生结果（差值、波长、相对误差）由
/// [MichelsonInterferometerViewModel] 在加载后重算。
class MichelsonDraft {
  const MichelsonDraft({required this.positions});

  /// 10 个位置读数输入文本。
  final List<String> positions;

  factory MichelsonDraft.fromJson(Map<String, dynamic> json) {
    return MichelsonDraft(
      positions: _stringListFromJson(json['positions']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'positions': positions,
      };

  factory MichelsonDraft.fromJsonString(String jsonString) {
    return MichelsonDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

List<String> _stringListFromJson(dynamic value) {
  if (value is! List) {
    return <String>[];
  }
  return value
      .map((dynamic element) => element is String ? element : '')
      .toList(growable: false);
}