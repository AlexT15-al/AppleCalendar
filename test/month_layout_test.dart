import 'package:apple_calendar/app/theme/cal_metrics.dart';
import 'package:apple_calendar/features/month/month_layout.dart';
import 'package:apple_calendar/shared/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final anchor = CalendarDate.monthIndex(DateTime(2026, 11));
  MonthLayout layout() => MonthLayout(
    anchor: anchor,
    rowHeight: 119,
    firstWeekday: DateTime.sunday,
  );

  test('forward rows walk each month: label, then its weeks, in order', () {
    final l = layout();
    var index = 0;
    var offset = 0.0;
    for (var month = anchor; month < anchor + 30; month++) {
      expect(l.topOf(month), closeTo(offset, 1e-6));
      final label = l.forwardRow(index++);
      expect(label, (month: month, week: null));
      offset += l.extentOf(label);
      for (var w = 0; w < l.weeksIn(month); w++) {
        final row = l.forwardRow(index++);
        expect(row, (month: month, week: w));
        offset += l.extentOf(row);
      }
    }
  });

  test('backward rows walk upward: last week first, label last', () {
    final l = layout();
    var index = 0;
    var offset = 0.0;
    for (var month = anchor - 1; month > anchor - 30; month--) {
      for (var w = l.weeksIn(month) - 1; w >= 0; w--) {
        final row = l.backwardRow(index++);
        expect(row, (month: month, week: w));
        offset -= l.extentOf(row);
      }
      final label = l.backwardRow(index++);
      expect(label, (month: month, week: null));
      offset -= l.extentOf(label);
      expect(l.topOf(month), closeTo(offset, 1e-6));
    }
  });

  test('monthAt agrees with topOf in both directions, from any cursor', () {
    final l = layout();
    for (final month in [anchor + 40, anchor - 40, anchor + 3, anchor]) {
      final top = l.topOf(month);
      expect(l.monthAt(top), month);
      expect(l.monthAt(top + CalMetrics.monthLabelRowHeight + 1), month);
      expect(l.monthAt(top - 1), month - 1);
    }
  });
}
