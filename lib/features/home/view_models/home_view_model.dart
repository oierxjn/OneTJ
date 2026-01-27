import 'dart:async';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/features/home/models/home_model.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({HomeModel? model})
      : _model = model ?? HomeModel(),
        _studentInfoController = StreamController<String>.broadcast(),
        _schoolCalendarController = StreamController<SchoolCalendarData>.broadcast(),
        _timetableController = StreamController<List<TimetableEntry>>.broadcast(),
        _studentErrorController = StreamController<Object>.broadcast(),
        _calendarErrorController = StreamController<Object>.broadcast(),
        _timetableErrorController = StreamController<Object>.broadcast();

  final HomeModel _model;
  final StreamController<String> _studentInfoController;
  final StreamController<SchoolCalendarData> _schoolCalendarController;
  final StreamController<List<TimetableEntry>> _timetableController;
  final StreamController<Object> _studentErrorController;
  final StreamController<Object> _calendarErrorController;
  final StreamController<Object> _timetableErrorController;

  Stream<String> get studentInfo => _studentInfoController.stream;
  Stream<SchoolCalendarData> get schoolCalendar => _schoolCalendarController.stream;
  Stream<List<TimetableEntry>> get timetableEntries => _timetableController.stream;
  Stream<Object> get studentErrors => _studentErrorController.stream;
  Stream<Object> get calendarErrors => _calendarErrorController.stream;
  Stream<Object> get timetableErrors => _timetableErrorController.stream;

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

  Future<void> loadCourseSchedule() async {
    try {
      final CourseScheduleData data = await _model.fetchCourseSchedule();
      final CourseScheduleRepository repo = CourseScheduleRepository.getInstance();
      await repo.saveCourseSchedule(data);
      final TimetableIndex index = const TimetableIndexBuilder().buildIndex(data);
      final List<TimetableEntry> entries = List<TimetableEntry>.from(index.allEntries)
        ..sort((a, b) {
          final int dayA = a.dayOfWeek ?? 0;
          final int dayB = b.dayOfWeek ?? 0;
          if (dayA != dayB) {
            return dayA.compareTo(dayB);
          }
          final int startA = a.timeStart ?? 0;
          final int startB = b.timeStart ?? 0;
          if (startA != startB) {
            return startA.compareTo(startB);
          }
          final int endA = a.timeEnd ?? 0;
          final int endB = b.timeEnd ?? 0;
          return endA.compareTo(endB);
        });
      _timetableController.add(entries);
    } catch (error) {
      _timetableErrorController.add(error);
    }
  }

  @override
  void dispose() {
    _studentInfoController.close();
    _schoolCalendarController.close();
    _timetableController.close();
    _studentErrorController.close();
    _calendarErrorController.close();
    _timetableErrorController.close();
    super.dispose();
  }
}
