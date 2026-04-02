import 'package:flutter/material.dart';

import 'package:onetj/app/constant/route_paths.dart';

enum PhysicsLabExperiment {
  michelsonInterferometer,
  diffractionGrating,
}

extension PhysicsLabExperimentMeta on PhysicsLabExperiment {
  IconData get icon {
    switch (this) {
      case PhysicsLabExperiment.michelsonInterferometer:
        return Icons.waves_outlined;
      case PhysicsLabExperiment.diffractionGrating:
        return Icons.blur_on_outlined;
    }
  }

  String get route {
    switch (this) {
      case PhysicsLabExperiment.michelsonInterferometer:
        return RoutePaths.homePhysicsLabMichelson;
      case PhysicsLabExperiment.diffractionGrating:
        return RoutePaths.homePhysicsLabDiffractionGrating;
    }
  }
}
