class FranckHertzDataPoint {
  const FranckHertzDataPoint({
    required this.voltage,
    required this.current,
  });

  final double voltage;
  final double current;
}

class FranckHertzSmoothedPoint {
  const FranckHertzSmoothedPoint({
    required this.voltage,
    required this.current,
  });

  final double voltage;
  final double current;
}

class FranckHertzFeaturePoint {
  const FranckHertzFeaturePoint({
    required this.voltage,
    required this.current,
  });

  final double voltage;
  final double current;
}

class FranckHertzMethodResult {
  const FranckHertzMethodResult({
    required this.featurePoints,
    required this.intervals,
    required this.averageInterval,
  });

  final List<FranckHertzFeaturePoint> featurePoints;
  final List<double> intervals;
  final double averageInterval;
}

class FranckHertzAnalysisResult {
  const FranckHertzAnalysisResult({
    required this.validPoints,
    required this.smoothedPoints,
    required this.peakResult,
    required this.valleyResult,
    required this.referenceVoltage,
    required this.finalExcitationPotential,
    required this.relativeErrorPercent,
  });

  final List<FranckHertzDataPoint> validPoints;
  final List<FranckHertzSmoothedPoint> smoothedPoints;
  final FranckHertzMethodResult? peakResult;
  final FranckHertzMethodResult? valleyResult;
  final double? referenceVoltage;
  final double? finalExcitationPotential;
  final double? relativeErrorPercent;

  bool get hasCompleteResult {
    return peakResult != null &&
        valleyResult != null &&
        finalExcitationPotential != null;
  }
}
