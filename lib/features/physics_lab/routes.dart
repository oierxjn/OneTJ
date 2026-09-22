import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';

import 'package:onetj/features/physics_lab/features/diffraction_grating/view_models/diffraction_grating_view_model.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/views/diffraction_grating_view.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/view_models/franck_hertz_view_model.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/views/franck_hertz_view.dart';
import 'package:onetj/features/physics_lab/features/michelson/view_models/michelson_interferometer_view_model.dart';
import 'package:onetj/features/physics_lab/features/michelson/views/michelson_interferometer_view.dart';
import 'package:onetj/features/physics_lab/features/michelson/application/michelson_draft_service.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/application/diffraction_grating_draft_service.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/application/franck_hertz_draft_service.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/view_models/bohr_twist_pendulum_view_model.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/views/bohr_twist_pendulum_view.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/application/bohr_twist_pendulum_draft_service.dart';
import 'package:onetj/features/physics_lab/views/physics_lab_view.dart';

/// 物理实验及其子实验的 Shell 外详情页面。
final List<GoRoute> physicsLabDetailRoutes = [
  GoRoute(
    path: RoutePaths.homePhysicsLab,
    name: 'physics-lab',
    builder: (context, state) => const PhysicsLabView(),
    routes: [
      GoRoute(
        path: 'michelson',
        name: 'physics-lab-michelson',
        builder: (context, state) => MichelsonInterferometerView(
          viewModel: MichelsonInterferometerViewModel(
            draftService: appLocator<MichelsonDraftService>(),
          ),
        ),
      ),
      GoRoute(
        path: 'diffraction-grating',
        name: 'physics-lab-diffraction-grating',
        builder: (context, state) => DiffractionGratingView(
          viewModel: DiffractionGratingViewModel(
            draftService: appLocator<DiffractionGratingDraftService>(),
          ),
        ),
      ),
      GoRoute(
        path: 'franck-hertz',
        name: 'physics-lab-franck-hertz',
        builder: (context, state) => FranckHertzView(
          viewModel: FranckHertzViewModel(
            draftService: appLocator<FranckHertzDraftService>(),
          ),
        ),
      ),
      GoRoute(
        path: 'bohr-twist-pendulum',
        name: 'physics-lab-bohr-twist-pendulum',
        builder: (context, state) => BohrTwistPendulumView(
          viewModel: BohrTwistPendulumViewModel(
            draftService: appLocator<BohrTwistPendulumDraftService>(),
          ),
        ),
      ),
    ],
  ),
];
