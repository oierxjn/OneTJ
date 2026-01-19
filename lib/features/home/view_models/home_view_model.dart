import 'dart:async';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/features/home/models/home_model.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({HomeModel? model})
      : _model = model ?? HomeModel(),
        _studentInfoController = StreamController<String>.broadcast(),
        _errorController = StreamController<Object>.broadcast();

  final HomeModel _model;
  final StreamController<String> _studentInfoController;
  final StreamController<Object> _errorController;

  Stream<String> get studentInfo => _studentInfoController.stream;
  Stream<Object> get errors => _errorController.stream;

  Future<void> loadStudentInfo() async {
    try {
      final String data = await _model.fetchStudentInfo();
      _studentInfoController.add(data);
    } catch (error) {
      _errorController.add(error);
    }
  }

  @override
  void dispose() {
    _studentInfoController.close();
    _errorController.close();
    super.dispose();
  }
}
