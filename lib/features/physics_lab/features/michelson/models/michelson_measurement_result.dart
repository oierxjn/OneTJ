class MichelsonMeasurementResult {
  const MichelsonMeasurementResult({
    required this.positions,
    required this.differencesMm,
    required this.wavelengthsNm,
    required this.averageWavelengthNm,
    required this.relativeErrorPercent,
  });

  final List<double> positions;
  final List<double> differencesMm;
  final List<double> wavelengthsNm;
  final double averageWavelengthNm;
  final double relativeErrorPercent;
}
