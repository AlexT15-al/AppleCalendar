/// Calendar arithmetic on local dates.
///
/// Days are always built with the `DateTime(y, m, d)` constructor, never by
/// adding `Duration(days: n)`: across a daylight-saving change a day is 23 or
/// 25 hours long, and duration arithmetic lands an hour off midnight — which is
/// how a calendar ends up showing an event on the wrong day twice a year.
abstract final class CalendarDate {
  /// Midnight at the start of [date]'s day.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// [date] moved by [days] calendar days, at midnight.
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// A dense integer per day, for indexing events. Not a timestamp — only
  /// ordering and equality are meaningful.
  static int dayKey(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  // ── Months as integers ─────────────────────────────────────────────────────
  //
  // The month grid scrolls through an unbounded run of months, so it addresses
  // them as a single integer rather than as (year, month) pairs: "three months
  // after this one" is then `+ 3`, with no carrying across year boundaries.

  static int monthIndex(DateTime date) => date.year * 12 + (date.month - 1);

  /// The first of the month for a [monthIndex].
  static DateTime monthStart(int index) =>
      DateTime(index ~/ 12, index % 12 + 1);

  // ── Weeks ──────────────────────────────────────────────────────────────────

  /// Which column [date] falls in, for a week starting on [firstWeekday]
  /// (`DateTime.monday` … `DateTime.sunday`).
  static int column(DateTime date, int firstWeekday) =>
      (date.weekday - firstWeekday) % 7;

  /// Empty cells before day 1 of the month.
  static int leadingBlanks(int monthIndex, int firstWeekday) =>
      column(monthStart(monthIndex), firstWeekday);

  /// How many week rows the month occupies: 4, 5 or 6.
  static int weeksInMonth(int monthIndex, int firstWeekday) {
    final start = monthStart(monthIndex);
    final cells =
        leadingBlanks(monthIndex, firstWeekday) +
        daysInMonth(start.year, start.month);
    return (cells + 6) ~/ 7;
  }

  /// The weekday of each column, in order, starting at [firstWeekday].
  static List<int> weekdayOrder(int firstWeekday) => [
    for (var i = 0; i < 7; i++) (firstWeekday - 1 + i) % 7 + 1,
  ];

  static bool isWeekend(int weekday) =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;
}
