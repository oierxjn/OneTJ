import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/grades/views/grades_view.dart';

final List<GoRoute> gradesRoutes = [
  GoRoute(
    path: RoutePaths.homeGrades,
    name: 'grades',
    builder: (context, state) => const GradesView(),
  ),
];
