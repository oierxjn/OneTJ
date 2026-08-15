import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/features/student_exams/view_models/student_exam_view_model.dart';
import 'package:onetj/features/student_exams/views/student_exams_view.dart';

/// 学生考试安排的 Shell 外详情页面。
final List<GoRoute> studentExamsDetailRoutes = <GoRoute>[
  GoRoute(
    path: RoutePaths.homeStudentExams,
    name: 'student-exams',
    builder: (context, state) => StudentExamsView(
      viewModel: appLocator<StudentExamViewModel>(),
    ),
  ),
];
