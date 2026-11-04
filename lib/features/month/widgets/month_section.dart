import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/cal_colors.dart';
import '../../../app/theme/cal_metrics.dart';
import '../../../data/event_store.dart';
import '../../../shared/calendar_date.dart';
import 'month_day_cell.dart';

/// One month of the grid: a label row with the month's name over the column
/// of its first day, then its weeks.
///
/// Every week row draws a hairline along its top, starting at the column of
/// its first day and running to the trailing edge — so a month that starts on
/// a Friday has a short rule over Friday and Saturday, and the rule under the
/// month's last week belongs to the next month instead. That is exactly the
/// stepped outline in the reference.
class MonthSection extends StatelessWidget {
  const MonthSection({
    super.key,
    required this.month,
    required this.rowHeight,
    required this.firstWeekday,
    required this.today,
    required this.store,
    this.onDayTap,
  });

  /// A `CalendarDate.monthIndex`.
  final int month;
  final double rowHeight;
  final int firstWeekday;
  final DateTime today;
  final EventStore store;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final start = CalendarDate.monthStart(month);
    final blanks = CalendarDate.leadingBlanks(month, firstWeekday);
    final days = CalendarDate.daysInMonth(start.year, start.month);
    final weeks = CalendarDate.weeksInMonth(month, firstWeekday);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = constraints.maxWidth / 7;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MonthLabel(
              start: start,
              column: blanks,
              columnWidth: columnWidth,
              isCurrentMonth:
                  start.year == today.year && start.month == today.month,
            ),
            for (var week = 0; week < weeks; week++)
              _WeekRow(
                firstCell: week * 7 - blanks,
                daysInMonth: days,
                start: start,
                columnWidth: columnWidth,
                rowHeight: rowHeight,
                firstWeekday: firstWeekday,
                today: today,
                store: store,
                onDayTap: onDayTap,
              ),
          ],
        );
      },
    );
  }
}

class _MonthLabel extends StatelessWidget {
  const _MonthLabel({
    required this.start,
    required this.column,
    required this.columnWidth,
    required this.isCurrentMonth,
  });

  final DateTime start;
  final int column;
  final double columnWidth;
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final name = DateFormat.MMM(locale).format(start);

    return SizedBox(
      height: CalMetrics.monthLabelRowHeight,
      child: Stack(
        children: [
          // Centred over the first day's column, but never pushed off either
          // edge: a month starting on Saturday keeps its name on screen.
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            child: Align(
              alignment: Alignment(
                // Column centre mapped onto -1…1 across the row.
                ((column + 0.5) / 7) * 2 - 1,
                0,
              ),
              child: Text(
                name,
                maxLines: 1,
                style: TextStyle(
                  color: isCurrentMonth
                      ? CalColors.accent.resolveFrom(context)
                      : CalColors.labelOf(context),
                  fontSize: CalMetrics.monthLabelSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.firstCell,
    required this.daysInMonth,
    required this.start,
    required this.columnWidth,
    required this.rowHeight,
    required this.firstWeekday,
    required this.today,
    required this.store,
    required this.onDayTap,
  });

  /// Zero-based day-of-month of this row's first column; negative for the
  /// blank cells before day 1.
  final int firstCell;
  final int daysInMonth;
  final DateTime start;
  final double columnWidth;
  final double rowHeight;
  final int firstWeekday;
  final DateTime today;
  final EventStore store;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstFilled = firstCell < 0 ? -firstCell : 0;
    final weekdays = CalendarDate.weekdayOrder(firstWeekday);

    return SizedBox(
      height: rowHeight,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: firstFilled * columnWidth,
            right: 0,
            height: CalMetrics.hairline,
            child: ColoredBox(color: CalColors.separatorOf(context)),
          ),
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: _cell(context, col, weekdays[col])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, int col, int weekday) {
    final dayIndex = firstCell + col;
    if (dayIndex < 0 || dayIndex >= daysInMonth) return const SizedBox.shrink();

    final day = DateTime(start.year, start.month, dayIndex + 1);
    return MonthDayCell(
      day: day,
      events: store.eventsOn(day),
      store: store,
      rowHeight: rowHeight,
      isToday: CalendarDate.isSameDay(day, today),
      isWeekend: CalendarDate.isWeekend(weekday),
      onTap: onDayTap == null ? null : () => onDayTap!(day),
    );
  }
}
