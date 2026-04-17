class FranckHertzMeasurementRow {
  const FranckHertzMeasurementRow({
    required this.index,
    required this.vg2kText,
    required this.ipText,
  });

  final int index;
  final String vg2kText;
  final String ipText;

  bool get hasAnyInput =>
      vg2kText.trim().isNotEmpty || ipText.trim().isNotEmpty;

  FranckHertzMeasurementRow copyWith({
    int? index,
    String? vg2kText,
    String? ipText,
  }) {
    return FranckHertzMeasurementRow(
      index: index ?? this.index,
      vg2kText: vg2kText ?? this.vg2kText,
      ipText: ipText ?? this.ipText,
    );
  }
}
