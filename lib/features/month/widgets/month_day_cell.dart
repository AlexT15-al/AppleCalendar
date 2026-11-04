import 'package:flutter/cupertino.dart';

import '../../../app/theme/cal_colors.dart';
import '../../../app/theme/cal_metrics.dart';
import '../../../data/event_store.dart';
import '../../../domain/calendar_event.dart';
import '../month_density.dart';
import 'month_event_chip.dart';

/// One day of the month grid: its number, and what is on it at the current
/// density.
///
/// Deliberately lean, because a scrolling month builds ~35 of these on the
/// frame it enters the screen: no gesture detector (the week row owns one for
/// all seven days), no animation of its own (the density cross-fade is derived
/// from [rowHeight]), and a plain Column instead of a Stack of positions.
class MonthDayCell extends StatelessWidget {
  const MonthDayCell({
    super.key,
    required this.day,
    required this.events,
    required this.store,
    required this.rowHeight,
    required this.isToday,
    required this.isWeekend,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final EventStore store;
  final double rowHeight;
  final bool isToday;
  final bool isWeekend;

  @override
  Widget build(BuildContext context) {
    final density = MonthDensity.forRowHeight(rowHeight);
    final opacity = MonthDensity.contentOpacity(rowHeight);

    Widget content = switch (density) {
      MonthDensity.compact => _CompactIndicator(events: events),
      MonthDensity.stacked => _StackedBars(events: events, store: store),
      MonthDensity.details => _DetailsList(
        events: events,
        store: store,
        height: rowHeight - CalMetrics.dayContentTop,
      ),
    };
    // Only mid-resize: at rest the opacity is exactly 1 and no layer is made.
    if (opacity < 1) content = Opacity(opacity: opacity, child: content);

    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: CalMetrics.dayNumberTop),
          Center(
            child: _DayNumber(
              day: day.day,
              isToday: isToday,
              isWeekend: isWeekend,
            ),
          ),
          const SizedBox(
            height:
                CalMetrics.dayContentTop -
                CalMetrics.dayNumberTop -
                CalMetrics.dayCircleSize,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CalMetrics.chipHorizontalInset,
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayNumber extends StatelessWidget {
  const _DayNumber({
    required this.day,
    required this.isToday,
    required this.isWeekend,
  });

  final int day;
  final bool isToday;
  final bool isWeekend;

  @override
  Widget build(BuildContext context) {
    final color = isToday
        ? CalColors.onAccent
        : isWeekend
        ? CalColors.weekendLabelOf(context)
        : CalColors.labelOf(context);

    return Container(
      width: CalMetrics.dayCircleSize,
      height: CalMetrics.dayCircleSize,
      alignment: Alignment.center,
      decoration: isToday
          ? BoxDecoration(
              color: CalColors.accent.resolveFrom(context),
              shape: BoxShape.circle,
            )
          : null,
      child: Text(
        '$day',
        style: TextStyle(
          color: color,
          fontSize: CalMetrics.dayNumberSize,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
          // Tabular, so "11" and "18" occupy the same width and the column of
          // numbers stays centred down the grid.
          fontFeatures: const [FontFeature.tabularFigures()],
          height: 1.0,
        ),
      ),
    );
  }
}

/// Compact: one quiet dot for "something is on this day".
class _CompactIndicator extends StatelessWidget {
  const _CompactIndicator({required this.events});

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: CalMetrics.compactDotSize,
        height: CalMetrics.compactDotSize,
        decoration: BoxDecoration(
          color: CalColors.tertiaryLabelOf(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Stacked: a bar per event in its calendar's colour.
class _StackedBars extends StatelessWidget {
  const _StackedBars({required this.events, required this.store});

  final List<CalendarEvent> events;
  final EventStore store;

  @override
  Widget build(BuildContext context) {
    final shown = events.take(CalMetrics.stackedMaxBars);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final event in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: CalMetrics.stackedBarGap),
            child: Container(
              height: CalMetrics.stackedBarHeight,
              decoration: BoxDecoration(
                color: store.calendarOf(event).color,
                borderRadius: BorderRadius.circular(
                  CalMetrics.stackedBarHeight / 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Details: titled chips, then "+N" for whatever does not fit.
class _DetailsList extends StatelessWidget {
  const _DetailsList({
    required this.events,
    required this.store,
    required this.height,
  });

  final List<CalendarEvent> events;
  final EventStore store;

  /// The room below the day number.
  final double height;

  static const double _step = CalMetrics.chipHeight + CalMetrics.chipGap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    // As many chips as fit outright; if not all of them do, give up one slot
    // to the "+N" line. This is what makes a three-event day show all three
    // while a ten-event day shows two and "+8".
    final fitAll = ((height - 4) / _step).floor();
    final int shown;
    if (events.length <= fitAll) {
      shown = events.length;
    } else {
      shown = ((height - 4 - CalMetrics.overflowRowHeight) / _step)
          .floor()
          .clamp(0, events.length);
    }
    final hidden = events.length - shown;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < shown; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: CalMetrics.chipGap),
            child: MonthEventChip(
              event: events[i],
              calendar: store.calendarOf(events[i]),
            ),
          ),
        if (hidden > 0)
          SizedBox(
            height: CalMetrics.overflowRowHeight,
            child: Center(
              child: Text(
                '+$hidden',
                style: TextStyle(
                  color: CalColors.secondaryLabelOf(context),
                  fontSize: CalMetrics.overflowTextSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
