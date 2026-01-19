import 'package:onetj/services/tongji.dart';

import 'package:onetj/repo/student_info_repository.dart';

class HomeModel {
  HomeModel({TongjiApi? api}) : _api = api ?? TongjiApi();

  final TongjiApi _api;

  Future<StudentInfoData> fetchStudentInfo() {
    return _api.fetchStudentInfo();
  }
}
