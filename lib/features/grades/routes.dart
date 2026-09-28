import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/grades/view_models/grades_view_model.dart';
import 'package:onetj/features/grades/views/grades_view.dart';

/// 成绩查询的 Shell 外详情页面。
final List<GoRoute> gradesDetailRoutes = [
  GoRoute(
    path: RoutePaths.homeGrades,
    name: 'grades',
    builder: (context, state) => GradesView(
      viewModel: GradesViewModel(
        dataService: appLocator<GradesDataService>(),
      ),
    ),
  ),
];
