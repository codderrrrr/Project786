/// Business-date helpers.
/// All business dates are calendar dates (`YYYY-MM-DD`) and are never routed
/// through timezone conversion, so a date can never shift by a day on a device
/// in another timezone.
class BizDate {
  BizDate._();

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Today as `YYYY-MM-DD` in the device's local calendar.
  static String todayYMD() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static bool isAfter(String ymd, String other) => ymd.compareTo(other) > 0;

  static bool isBefore(String ymd, String other) => ymd.compareTo(other) < 0;

  static bool isSame(String ymd, String other) => ymd == other;

  /// Whole days from [from] to [to] (negative when [to] is in the past).
  static int daysBetween(String from, String to) {
    final a = DateTime.tryParse(from);
    final b = DateTime.tryParse(to);
    if (a == null || b == null) return 0;
    final aDay = DateTime(a.year, a.month, a.day);
    final bDay = DateTime(b.year, b.month, b.day);
    return bDay.difference(aDay).inDays;
  }

  /// Human label for today, e.g. `12 October 2026`.
  static String todayLabel() {
    final now = DateTime.now();
    return '${now.day} ${_months[now.month - 1]} ${now.year}';
  }

  /// Returns a [DateTime] from a `YYYY-MM-DD` string.
  static DateTime fromYMD(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return DateTime.now();
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12) return DateTime.now();
    return DateTime(y, m, d);
  }

  /// Returns the day name (e.g. 'Monday') from a `YYYY-MM-DD` string.
  static String dayName(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return '';
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12) return '';
    final date = DateTime(y, m, d);
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1]; // weekday is 1=Monday, 7=Sunday
  }

  /// Turns `2026-10-12` into `12 Oct 2026`.
  static String prettyYMD(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12) return ymd;
    return '$d ${_months[m - 1].substring(0, 3)} $y';
  }

  /// Turns `2026-10` into `October 2026`, for grouping a ledger by month.
  static String monthLabel(String ym) {
    final parts = ym.split('-');
    if (parts.length < 2) return ym;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (y == null || m == null || m < 1 || m > 12) return ym;
    return '${_months[m - 1]} $y';
  }

  /// `12 Oct 2026` shortened to `12 Oct` when the year is the current one, so a
  /// list of recent records stays readable.
  static String shortYMD(String ymd) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null || m < 1 || m > 12) return ymd;
    final month = _months[m - 1].substring(0, 3);
    return y == DateTime.now().year ? '$d $month' : '$d $month $y';
  }

  /// Shifts a `YYYY-MM-DD` date by whole months, clamping the day so that
  /// 31 Jan + 1 month becomes 28 (or 29) Feb.
  static String addMonths(String ymd, int months) {
    final parts = ymd.split('-');
    if (parts.length != 3) return ymd;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return ymd;
    final zeroBased = (m - 1) + months;
    final newYear = y + (zeroBased ~/ 12);
    final newMonth = (zeroBased % 12) + 1;
    final lastDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = d > lastDay ? lastDay : d;
    return '${newYear.toString().padLeft(4, '0')}-'
        '${newMonth.toString().padLeft(2, '0')}-'
        '${newDay.toString().padLeft(2, '0')}';
  }

  /// Number of months for a billing period, or `null` for one-off services.
  static int? monthsForPeriod(String period) => switch (period) {
    'monthly' => 1,
    'quarterly' => 3,
    'yearly' => 12,
    _ => null,
  };
}