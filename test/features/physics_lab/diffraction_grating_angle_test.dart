import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/models/diffraction_grating_angle.dart';

void main() {
  group('DiffractionGratingAngle.tryParse', () {
    test('parses decimal degrees', () {
      final DiffractionGratingAngle? angle =
          DiffractionGratingAngle.tryParse('171.5');

      expect(angle, isNotNull);
      expect(angle!.degrees, closeTo(171.5, 1e-9));
    });

    test('parses degree minute second format', () {
      final DiffractionGratingAngle? angle =
          DiffractionGratingAngle.tryParse('173°34\'40"');

      expect(angle, isNotNull);
      expect(angle!.degrees, closeTo(173.5777777778, 1e-9));
    });

    test('returns null for invalid minutes', () {
      expect(
        DiffractionGratingAngle.tryParse('10°75\''),
        isNull,
      );
    });
  });

  test('circularDifferenceDegrees handles wraparound', () {
    expect(
      DiffractionGratingAngle.circularDifferenceDegrees(6.1, 351.0333333333),
      closeTo(15.0666666667, 1e-9),
    );
  });
}
