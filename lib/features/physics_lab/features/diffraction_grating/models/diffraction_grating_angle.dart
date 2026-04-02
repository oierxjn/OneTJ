class DiffractionGratingAngle {
  const DiffractionGratingAngle._({
    required this.degrees,
  });

  final double degrees;

  static DiffractionGratingAngle? tryParse(String text) {
    final String normalized = text
        .trim()
        .replaceAll('′', "'")
        .replaceAll('’', "'")
        .replaceAll('＇', "'")
        .replaceAll('″', '"')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('°', ' ')
        .replaceAll("'", ' ')
        .replaceAll('"', ' ')
        .replaceAll(':', ' ')
        .replaceAll('：', ' ');
    if (normalized.isEmpty) {
      return null;
    }

    final List<String> parts = normalized
        .split(RegExp(r'\s+'))
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty || parts.length > 3) {
      return null;
    }

    final double? degreePart = double.tryParse(parts[0]);
    if (degreePart == null) {
      return null;
    }

    final bool negative = degreePart < 0;
    final double degreeMagnitude = degreePart.abs();
    final double minutes =
        parts.length >= 2 ? double.tryParse(parts[1]) ?? -1 : 0;
    final double seconds =
        parts.length >= 3 ? double.tryParse(parts[2]) ?? -1 : 0;
    if (minutes < 0 || minutes >= 60 || seconds < 0 || seconds >= 60) {
      return null;
    }

    final double value = degreeMagnitude + (minutes / 60) + (seconds / 3600);
    return DiffractionGratingAngle._(
      degrees: negative ? -value : value,
    );
  }

  static double circularDifferenceDegrees(double a, double b) {
    final double raw = (a - b).abs() % 360;
    return raw > 180 ? 360 - raw : raw;
  }

  static String formatDegrees(
    double value, {
    String degreeSymbol = '°',
  }) {
    final int totalSeconds = (value * 3600).round();
    final int wholeDegrees = totalSeconds ~/ 3600;
    final int remainingSeconds = totalSeconds % 3600;
    final int wholeMinutes = remainingSeconds ~/ 60;
    final int seconds = remainingSeconds % 60;
    if (seconds == 0) {
      return '$wholeDegrees$degreeSymbol$wholeMinutes\'';
    }
    return '$wholeDegrees$degreeSymbol$wholeMinutes\'$seconds"';
  }
}
