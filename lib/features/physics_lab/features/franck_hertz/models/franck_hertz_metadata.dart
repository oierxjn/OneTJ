class FranckHertzMetadata {
  const FranckHertzMetadata({
    required this.vfText,
    required this.vg1kText,
    required this.vg2aText,
  });

  final String vfText;
  final String vg1kText;
  final String vg2aText;

  bool get hasAnyInput =>
      vfText.trim().isNotEmpty ||
      vg1kText.trim().isNotEmpty ||
      vg2aText.trim().isNotEmpty;
}
