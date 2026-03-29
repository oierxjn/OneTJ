import 'package:flutter/material.dart';

import 'package:onetj/app/constant/route_paths.dart';

enum PhysicsLabExperiment {
  michelsonInterferometer,
}

extension PhysicsLabExperimentMeta on PhysicsLabExperiment {
  IconData get icon {
    switch (this) {
      case PhysicsLabExperiment.michelsonInterferometer:
        return Icons.waves_outlined;
    }
  }

  String get route {
    switch (this) {
      case PhysicsLabExperiment.michelsonInterferometer:
        return RoutePaths.homePhysicsLabMichelson;
    }
  }
}
