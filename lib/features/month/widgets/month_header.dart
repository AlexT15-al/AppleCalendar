import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/cal_colors.dart';
import '../../../app/theme/cal_metrics.dart';
import '../../../app/theme/cal_motion.dart';
import '../../../shared/calendar_date.dart';

/// The sticky top of Month view, under the navigation bar: the visible month's
/// name in large-title type, then the S M T W T F S row and a hairline.
///
/// It floats over the grid rather than scrolling with it. The grid passes
/// underneath, frosted by the scaffold's progressive edge blur, and this layer
/// adds a soft wash of the page colour so the type stays crisp over whatever is
/// passing behind it.
class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.month,
    required this.today,
    required this.firstWeekday,
    required this.topInset,
  });

  /// The month whose name is shown — whichever is under the header now.
  final int month;
  final DateTime today;
  final int firstWeekday;

  /// Status bar plus navigation bar: where the header's own content starts.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final page = CalColors.background.resolveFrom(context);
    final locale = Localizations.localeOf(context).toString();
    final start = CalendarDate.monthStart(month);
    final showsToday = start.year == today.year && start.month == today.month;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Frosted at the top, where the bar's capsules float, and solid by
            // the weekday row: in the reference the grid is a blur behind the
            // title but never shows through the letters.
            colors: [
              page.withValues(alpha: 0.8),
              page.withValues(alpha: 0.95),
              page,
            ],
            stops: const [0, 0.6, 0.8],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: CalMetrics.monthTitleRowHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CalMetrics.pagePadding,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: CalMotion.of(
                        context,
                        CalMotion.titleSwapDuration,
                      ),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.centerLeft,
                        children: [...previous, ?current],
                      ),
                      child: Text(
                        DateFormat.MMMM(locale).format(start),
                        key: ValueKey(month),
                        style: TextStyle(
                          color: CalColors.labelOf(context),
                          fontSize: CalMetrics.monthTitleSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: CalMetrics.monthTitleTracking,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: CalMetrics.weekdayRowHeight,
                child: _WeekdayLetters(
                  firstWeekday: firstWeekday,
                  // Today's letter is red only while today's month is the one
                  // on screen; in any other month it would point at nothing.
                  todayWeekday: showsToday ? today.weekday : null,
                  locale: locale,
                ),
              ),
              Container(
                height: CalMetrics.hairline,
                color: CalColors.separatorOf(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayLetters extends StatelessWidget {
  const _WeekdayLetters({
    required this.firstWeekday,
    required this.todayWeekday,
    required this.locale,
  });

  final int firstWeekday;
  final int? todayWeekday;
  final String locale;

  @override
  Widget build(BuildContext context) {
    // A fixed week (2023-01-01 was a Sunday) gives one date per weekday to
    // format, so the letters come from the locale rather than a hardcoded
    // "SMTWTFS".
    final narrow = DateFormat.EEEEE(locale);
    final base = DateTime(2023, 1, 1);

    return Row(
      children: [
        for (final weekday in CalendarDate.weekdayOrder(firstWeekday))
          Expanded(
            child: Center(
              child: Text(
                narrow.format(DateTime(2023, 1, base.day + weekday % 7)),
                style: TextStyle(
                  color: weekday == todayWeekday
                      ? CalColors.accent.resolveFrom(context)
                      : CalendarDate.isWeekend(weekday)
                      ? CalColors.weekendLabelOf(context)
                      : CalColors.labelOf(context),
                  fontSize: CalMetrics.weekdayLetterSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
