import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../app/theme/cal_colors.dart';
import '../../../app/theme/cal_metrics.dart';
import '../../../data/event_store.dart';
import '../../../shared/calendar_date.dart';
import 'month_day_cell.dart';

/// The row above a month's first week, carrying its name over the column of
/// its first day ("May" at the bottom of the reference).
class MonthLabelRow extends StatelessWidget {
  const MonthLabelRow({
    super.key,
    required this.month,
    required this.firstWeekday,
    required this.today,
  });

  /// A `CalendarDate.monthIndex`.
  final int month;
  final int firstWeekday;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final start = CalendarDate.monthStart(month);
    final column = CalendarDate.leadingBlanks(month, firstWeekday);
    final locale = Localizations.localeOf(context).toString();
    final isCurrentMonth =
        start.year == today.year && start.month == today.month;

    return Align(
      // Centred over the first day's column — the column centre mapped onto
      // -1…1 across the row — and sitting low in the row, just above the rule.
      // Align never pushes the name off either edge, so a month starting on a
      // Saturday keeps it on screen.
      alignment: AlignmentDirectional(((column + 0.5) / 7) * 2 - 1, 0.6),
      child: Text(
        DateFormat.MMM(locale).format(start),
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
    );
  }
}

/// One week of a month.
///
/// Draws a hairline along its top, starting at the column of its first day
/// and running to the trailing edge — so a month that starts on a Friday has a
/// short rule over Friday and Saturday, and the rule under a month's last week
/// belongs to the next month instead. That is the stepped outline in the
/// reference.
///
/// Each week is its own item in the scrolling list rather than part of a
/// whole-month item. A month is ~35 cells and ~100 pieces of text; built as one
/// item it lands on a single frame as it scrolls in, which is a visible hitch.
/// Built a week at a time, the same work spreads across the frames the month
/// takes to arrive.
class MonthWeekRow extends StatelessWidget {
  const MonthWeekRow({
    super.key,
    required this.month,
    required this.week,
    required this.rowHeight,
    required this.firstWeekday,
    required this.today,
    required this.store,
    this.onDayTap,
  });

  final int month;

  /// Zero-based week within [month].
  final int week;
  final double rowHeight;
  final int firstWeekday;
  final DateTime today;
  final EventStore store;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final start = CalendarDate.monthStart(month);
    final daysInMonth = CalendarDate.daysInMonth(start.year, start.month);
    // Day-of-month (zero-based) of this row's first column; negative for the
    // blank cells before day 1.
    final firstCell =
        week * 7 - CalendarDate.leadingBlanks(month, firstWeekday);
    final firstFilled = firstCell < 0 ? -firstCell : 0;
    final weekdays = CalendarDate.weekdayOrder(firstWeekday);

    Widget cell(int col) {
      final dayIndex = firstCell + col;
      if (dayIndex < 0 || dayIndex >= daysInMonth) {
        return const SizedBox.shrink();
      }
      final day = DateTime(start.year, start.month, dayIndex + 1);
      return MonthDayCell(
        day: day,
        events: store.eventsOn(day),
        store: store,
        rowHeight: rowHeight,
        isToday: CalendarDate.isSameDay(day, today),
        isWeekend: CalendarDate.isWeekend(weekdays[col]),
      );
    }

    Widget row = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FractionallySizedBox(
            widthFactor: (7 - firstFilled) / 7,
            child: Container(
              height: CalMetrics.hairline,
              color: CalColors.separatorOf(context),
            ),
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var col = 0; col < 7; col++) Expanded(child: cell(col)),
            ],
          ),
        ),
      ],
    );

    // One recogniser for the whole week rather than one per day.
    final onDayTap = this.onDayTap;
    if (onDayTap != null) {
      row = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final box = context.findRenderObject()! as RenderBox;
          var col = (details.localPosition.dx / box.size.width * 7).floor();
          if (Directionality.of(context) == TextDirection.rtl) col = 6 - col;
          final dayIndex = firstCell + col.clamp(0, 6);
          if (dayIndex < 0 || dayIndex >= daysInMonth) return;
          onDayTap(DateTime(start.year, start.month, dayIndex + 1));
        },
        child: row,
      );
    }
    return row;
  }
}
