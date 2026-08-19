import 'dart:convert';

/// 波尔扭摆实验的持久化草稿。
///
/// 只保存原始输入文本，计算结果由 `BohrTwistPendulumViewModel` 在加载后重算。
class BohrTwistPendulumDraft {
  const BohrTwistPendulumDraft({
    required this.periodText,
    required this.periodTableText,
    required this.amplitudeTableText,
  });

  /// 自由振动单行周期输入文本。
  final String periodText;

  /// 自由振动周期表格数据输入文本。
  final String periodTableText;

  /// 阻尼振动振幅表格数据输入文本。
  final String amplitudeTableText;

  factory BohrTwistPendulumDraft.fromJson(Map<String, dynamic> json) {
    return BohrTwistPendulumDraft(
      periodText: json['periodText'] as String? ?? '',
      periodTableText: json['periodTableText'] as String? ?? '',
      amplitudeTableText: json['amplitudeTableText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'periodText': periodText,
        'periodTableText': periodTableText,
        'amplitudeTableText': amplitudeTableText,
      };

  factory BohrTwistPendulumDraft.fromJsonString(String jsonString) {
    return BohrTwistPendulumDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}
