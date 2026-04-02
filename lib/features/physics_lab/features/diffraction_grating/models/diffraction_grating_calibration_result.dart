import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_measurement_result.dart';

class DiffractionGratingCalibrationRowResult {
  const DiffractionGratingCalibrationRowResult({
    required this.order,
    required this.measurement,
    required this.gratingConstantMm,
  });

  final int order;
  final DiffractionGratingMeasurementResult measurement;
  final double gratingConstantMm;
}

class DiffractionGratingCalibrationResult {
  const DiffractionGratingCalibrationResult({
    required this.referenceWavelengthNm,
    required this.rows,
    required this.averageGratingConstantMm,
  });

  final double referenceWavelengthNm;
  final List<DiffractionGratingCalibrationRowResult> rows;
  final double averageGratingConstantMm;
}
