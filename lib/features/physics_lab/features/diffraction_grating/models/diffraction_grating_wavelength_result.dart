import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_measurement_result.dart';

class DiffractionGratingWavelengthRowResult {
  const DiffractionGratingWavelengthRowResult({
    required this.order,
    required this.measurement,
    required this.wavelengthNm,
  });

  final int order;
  final DiffractionGratingMeasurementResult measurement;
  final double wavelengthNm;
}

class DiffractionGratingWavelengthGroupResult {
  const DiffractionGratingWavelengthGroupResult({
    required this.averageGratingConstantMm,
    required this.referenceWavelengthNm,
    required this.rows,
    required this.averageWavelengthNm,
    required this.relativeErrorPercent,
  });

  final double averageGratingConstantMm;
  final double referenceWavelengthNm;
  final List<DiffractionGratingWavelengthRowResult> rows;
  final double averageWavelengthNm;
  final double relativeErrorPercent;
}
