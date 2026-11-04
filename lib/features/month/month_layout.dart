import '../../app/theme/cal_metrics.dart';
import '../../shared/calendar_date.dart';

/// Where every month sits in the endlessly scrolling month grid.
///
/// The grid is a `CustomScrollView` centred on [anchor]: scroll offset 0 is the
/// top of the anchor month's section, earlier months live at negative offsets
/// and later ones at positive. Every section's height is known without laying
/// it out — a label row plus 4, 5 or 6 week rows of [rowHeight] — so the grid
/// can answer "where is March?" and "which month is at this offset?" with
/// arithmetic, which is what lets Today scroll to an exact pixel and the
/// sticky title follow the scroll without measuring anything.
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

  int weeksIn(int month) => CalendarDate.weeksInMonth(month, firstWeekday);

  double sectionHeight(int month) =>
      CalMetrics.monthLabelRowHeight + weeksIn(month) * rowHeight;

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
}
