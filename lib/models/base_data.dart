/// 基础数据类，所有缓存数据都必须实现该类
///
/// 建议补上fromJson工厂方法
abstract class BaseData {
  const BaseData();
  Map<String, dynamic> toJson();
}
