import 'package:onetj/services/tongji.dart';

class HomeModel {
  HomeModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

  Future<String> fetchStudentInfo() {
    return _api.fetchStudentInfo();
  }
}
