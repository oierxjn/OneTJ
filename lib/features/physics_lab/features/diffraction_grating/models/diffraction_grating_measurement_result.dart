class DiffractionGratingMeasurementResult {
  const DiffractionGratingMeasurementResult({
    required this.readingsDegrees,
    required this.firstDifferenceDegrees,
    required this.secondDifferenceDegrees,
    required this.gammaDegrees,
    required this.sinGamma,
  });

  final List<double> readingsDegrees;
  final double firstDifferenceDegrees;
  final double secondDifferenceDegrees;
  final double gammaDegrees;
  final double sinGamma;
}
