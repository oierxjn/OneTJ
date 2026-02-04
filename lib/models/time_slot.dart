class TimeSlot {
  const TimeSlot({
    required this.startMinutes,
  });

  final List<int> startMinutes;

  static const TimeSlot defaultConfig = TimeSlot(
    startMinutes: [
      8 * 60,
      8 * 60 + 50,
      10 * 60,
      10 * 60 + 50,
      13 * 60 + 30,
      14 * 60 + 20,
      15 * 60 + 30,
      16 * 60 + 20,
      18 * 60 + 30,
      19 * 60 + 20,
      20 * 60 + 10,
    ],
  );

  static String formatMinutes(int minutes) {
    if (minutes < 0) {
      return '';
    }
    final int hour = minutes ~/ 60;
    final int minute = minutes % 60;
    final String h = hour.toString().padLeft(2, '0');
    final String m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
