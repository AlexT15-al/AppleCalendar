import '../../app/theme/cal_metrics.dart';
import '../../shared/calendar_date.dart';

/// One row of the month grid: a month's label row ([week] == null) or one of
/// its weeks.
typedef MonthRow = ({int month, int? week});

/// Where every month and every row sits in the endlessly scrolling month grid.
///
/// The grid is a `CustomScrollView` centred on [anchor]: scroll offset 0 is the
/// top of the anchor month's label row, earlier months live at negative offsets
/// and later ones at positive. Every row's height is known without laying it
/// out — a label row is [CalMetrics.monthLabelRowHeight], a week is
/// [rowHeight] — so the grid can answer "where is March?" and "which month is
/// at this offset?" with arithmetic. That is what lets Today scroll to an exact
/// pixel, the sticky title follow the scroll without measuring anything, and
/// the list skip laying out rows it jumps over.
///
/// The list itself is two slivers of rows: forward from the anchor month, and
/// backward from the month before it (growing upward, so its index 0 is the
/// last week of the previous month).
class MonthLayout {
  MonthLayout({
    required this.anchor,
    required this.rowHeight,
    required this.firstWeekday,
  });

  final int anchor;
  final double rowHeight;
  final int firstWeekday;

  // The last answer to monthAt, so the next one walks from there. Scrolling
  // moves a month or two between frames, so this makes the lookup O(1) in
  // practice however far from the anchor the user has scrolled.
  int _cursorMonth = 0;
  double _cursorTop = 0;
  bool _hasCursor = false;

  // Row index of the first row of each month, forward from the anchor and
  // backward from the month before it. Extended on demand; never shrinks.
  final List<int> _forwardStarts = [0];
  final List<int> _backwardStarts = [0];

  int weeksIn(int month) => CalendarDate.weeksInMonth(month, firstWeekday);

  int _rowsIn(int month) => 1 + weeksIn(month);

  double sectionHeight(int month) =>
      CalMetrics.monthLabelRowHeight + weeksIn(month) * rowHeight;

  double extentOf(MonthRow row) =>
      row.week == null ? CalMetrics.monthLabelRowHeight : rowHeight;

  /// Scroll offset of the top of [month]'s section (its label row).
  double topOf(int month) {
    var top = 0.0;
    if (month >= anchor) {
      for (var m = anchor; m < month; m++) {
        top += sectionHeight(m);
      }
    } else {
      for (var m = month; m < anchor; m++) {
        top -= sectionHeight(m);
      }
    }
    return top;
  }

  /// Scroll offset of the top of [month]'s first week row.
  double firstWeekTopOf(int month) =>
      topOf(month) + CalMetrics.monthLabelRowHeight;

  /// The month whose section contains scroll offset [offset].
  int monthAt(double offset) {
    if (!_hasCursor) {
      _cursorMonth = anchor;
      _cursorTop = 0;
      _hasCursor = true;
    }
    var month = _cursorMonth;
    var top = _cursorTop;
    while (offset < top) {
      month--;
      top -= sectionHeight(month);
    }
    while (offset >= top + sectionHeight(month)) {
      top += sectionHeight(month);
      month++;
    }
    _cursorMonth = month;
    _cursorTop = top;
    return month;
  }

  // ── Row indexing ───────────────────────────────────────────────────────────

  /// The row at [index] of the forward sliver (the anchor month onward).
  MonthRow forwardRow(int index) {
    final k = _monthSlot(_forwardStarts, index, (k) => anchor + k);
    final month = anchor + k;
    final row = index - _forwardStarts[k];
    return (month: month, week: row == 0 ? null : row - 1);
  }

  /// The row at [index] of the backward sliver, counted upward from the last
  /// week of the month before the anchor.
  MonthRow backwardRow(int index) {
    final k = _monthSlot(_backwardStarts, index, (k) => anchor - 1 - k);
    final month = anchor - 1 - k;
    // Counted from the bottom: 0 is the last week, the label row is last.
    final fromBottom = index - _backwardStarts[k];
    final row = _rowsIn(month) - 1 - fromBottom;
    return (month: month, week: row == 0 ? null : row - 1);
  }

  /// Which month slot [index] falls in, extending [starts] as needed.
  int _monthSlot(List<int> starts, int index, int Function(int) monthOf) {
    while (starts.last <= index) {
      final k = starts.length - 1;
      starts.add(starts.last + _rowsIn(monthOf(k)));
    }
    // Binary search for the last start <= index.
    var lo = 0;
    var hi = starts.length - 2;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (starts[mid] <= index) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }
}
