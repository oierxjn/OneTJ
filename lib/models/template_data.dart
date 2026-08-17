import 'package:onetj/models/base_data.dart';

class TemplateData extends BaseData {
  const TemplateData({required this.items}) : super();

  final List<Map<String, dynamic>> items;

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    final Object? rawItems = json['items'];
    final List<Map<String, dynamic>> items = rawItems is List<dynamic>
        ? rawItems.whereType<Map<String, dynamic>>().toList()
        : const [];
    return TemplateData(items: items);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items,
    };
  }
}
