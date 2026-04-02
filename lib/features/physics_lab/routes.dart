import 'package:go_router/go_router.dart';

import 'package:onetj/features/physics_lab/features/diffraction_grating/views/diffraction_grating_view.dart';
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
      GoRoute(
        path: 'diffraction-grating',
        name: 'physics-lab-diffraction-grating',
        builder: (context, state) => const DiffractionGratingView(),
      ),
    ],
  ),
];
