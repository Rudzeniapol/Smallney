/// Calendar dates are DateTime values at UTC midnight (no time zone arithmetic surprises).
abstract final class Dates {
  static DateTime of(int year, int month, int day) => DateTime.utc(year, month, day);

  /// The calendar date of a local timestamp.
  static DateTime dateOf(DateTime local) => DateTime.utc(local.year, local.month, local.day);

  static String iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime parse(String iso) {
    final parts = iso.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  static DateTime addDays(DateTime date, int days) => DateTime.utc(date.year, date.month, date.day + days);

  static int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

  static bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

/// The user's financial month, named after the calendar month it starts in (server rule, D32).
class FinancialMonth implements Comparable<FinancialMonth> {
  const FinancialMonth(this.year, this.month);

  final int year;
  final int month;

  factory FinancialMonth.containing(DateTime date, int firstDay) {
    final m = FinancialMonth(date.year, date.month);
    return date.day >= firstDay ? m : m.add(-1);
  }

  FinancialMonth add(int months) {
    final index = year * 12 + month - 1 + months;
    return FinancialMonth(index ~/ 12, index % 12 + 1);
  }

  DateTime start(int firstDay) => DateTime.utc(year, month, firstDay);

  DateTime end(int firstDay) => Dates.addDays(add(1).start(firstDay), -1);

  @override
  int compareTo(FinancialMonth other) => (year * 12 + month).compareTo(other.year * 12 + other.month);

  @override
  bool operator ==(Object other) => other is FinancialMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}
