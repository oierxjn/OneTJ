import 'dart:async';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/features/home/models/home_model.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({HomeModel? model})
      : _model = model ?? HomeModel(),
        _studentInfoController = StreamController<String>.broadcast(),
        _schoolCalendarController = StreamController<SchoolCalendarData>.broadcast(),
        _studentErrorController = StreamController<Object>.broadcast(),
        _calendarErrorController = StreamController<Object>.broadcast();

  final HomeModel _model;
  final StreamController<String> _studentInfoController;
  final StreamController<SchoolCalendarData> _schoolCalendarController;
  final StreamController<Object> _studentErrorController;
  final StreamController<Object> _calendarErrorController;

  Stream<String> get studentInfo => _studentInfoController.stream;
  Stream<SchoolCalendarData> get schoolCalendar => _schoolCalendarController.stream;
  Stream<Object> get studentErrors => _studentErrorController.stream;
  Stream<Object> get calendarErrors => _calendarErrorController.stream;

  Future<void> loadStudentInfo() async {
    try {
      final StudentInfoData data = await _model.fetchStudentInfo();
      _studentInfoController.add("姓名：${data.name}\n学号：${data.userId}");
    } catch (error) {
      _studentErrorController.add(error);
    }
  }



  Future<void> loadSchoolCalendar() async {
    try {
      final SchoolCalendarData data = await _model.fetchSchoolCalendar();
      final SchoolCalendarRepository repo = SchoolCalendarRepository.getInstance();
      await repo.saveSchoolCalendar(data);
      _schoolCalendarController.add(data);
    } catch (error) {
      _calendarErrorController.add(error);
    }
  }

  @override
  void dispose() {
    _studentInfoController.close();
    _schoolCalendarController.close();
    _studentErrorController.close();
    _calendarErrorController.close();
    super.dispose();
  }
}
