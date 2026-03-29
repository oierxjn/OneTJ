class MichelsonMeasurementResult {
  const MichelsonMeasurementResult({
    required this.positions,
    required this.differencesMm,
    required this.averageDifferenceMm,
    required this.wavelengthNm,
    required this.relativeErrorPercent,
  });

  final List<double> positions;
  final List<double> differencesMm;
  final double averageDifferenceMm;
  final double wavelengthNm;
  final double relativeErrorPercent;
}
