import 'dart:convert';

/// 光栅衍射实验的持久化草稿。
///
/// 只保存原始输入文本，派生结果（光栅常数、波长、相对误差）由
/// [DiffractionGratingViewModel] 在加载后重算。
class DiffractionGratingDraft {
  const DiffractionGratingDraft({
    required this.calibrationTexts,
    required this.wavelengthTexts,
    required this.referenceWavelengthTexts,
    required this.calibrationReferenceText,
  });

  /// 校准读数输入文本，二维结构（行 × 读数）。
  final List<List<String>> calibrationTexts;

  /// 波长读数输入文本，三维结构（组 × 行 × 读数）。
  final List<List<List<String>>> wavelengthTexts;

  /// 各组参考波长输入文本。
  final List<String> referenceWavelengthTexts;

  /// 校准参考波长输入文本。
  final String calibrationReferenceText;

  factory DiffractionGratingDraft.fromJson(Map<String, dynamic> json) {
    return DiffractionGratingDraft(
      calibrationTexts: _stringList2dFromJson(json['calibrationTexts']),
      wavelengthTexts: _stringList3dFromJson(json['wavelengthTexts']),
      referenceWavelengthTexts:
          _stringListFromJson(json['referenceWavelengthTexts']),
      calibrationReferenceText:
          json['calibrationReferenceText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'calibrationTexts': calibrationTexts,
        'wavelengthTexts': wavelengthTexts,
        'referenceWavelengthTexts': referenceWavelengthTexts,
        'calibrationReferenceText': calibrationReferenceText,
      };

  factory DiffractionGratingDraft.fromJsonString(String jsonString) {
    return DiffractionGratingDraft.fromJson(
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

List<List<String>> _stringList2dFromJson(dynamic value) {
  if (value is! List) {
    return <List<String>>[];
  }
  return value
      .map((dynamic element) => _stringListFromJson(element))
      .toList(growable: false);
}

List<List<List<String>>> _stringList3dFromJson(dynamic value) {
  if (value is! List) {
    return <List<List<String>>>[];
  }
  return value
      .map((dynamic element) => _stringList2dFromJson(element))
      .toList(growable: false);
}