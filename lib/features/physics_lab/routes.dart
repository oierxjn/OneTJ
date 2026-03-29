import 'package:go_router/go_router.dart';

import 'package:onetj/features/physics_lab/features/michelson/views/michelson_interferometer_view.dart';
import 'package:onetj/features/physics_lab/views/physics_lab_view.dart';

final List<GoRoute> physicsLabRoutes = [
  GoRoute(
    path: 'physics-lab',
    name: 'physics-lab',
    builder: (context, state) => const PhysicsLabView(),
    routes: [
      GoRoute(
        path: 'michelson',
        name: 'physics-lab-michelson',
        builder: (context, state) => const MichelsonInterferometerView(),
      ),
    ],
  ),
];
