import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/features/cet_score/view_models/cet_score_view_model.dart';
import 'package:onetj/features/cet_score/views/cet_score_view.dart';

/// 四六级查询的 Shell 外详情页面。
final List<GoRoute> cetScoreDetailRoutes = <GoRoute>[
  GoRoute(
    path: RoutePaths.homeCetScore,
    name: 'cet-score',
    builder: (context, state) => CetScoreView(
      viewModel: appLocator<CetScoreViewModel>(),
    ),
  ),
];
