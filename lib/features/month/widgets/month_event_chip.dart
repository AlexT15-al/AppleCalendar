import 'package:flutter/cupertino.dart';

import '../../../app/theme/cal_colors.dart';
import '../../../app/theme/cal_metrics.dart';
import '../../../domain/calendar_event.dart';
import '../../../domain/calendar_source.dart';
import '../../../shared/event_palette.dart';

/// One entry in a day cell at Details density.
///
/// Three looks, all from `reference/ios26_month_details_light.png`:
///
/// - **Event** — a squircle tinted with the calendar colour, its title in the
///   darkened ink. A subscribed calendar's glyph (the holiday star, the
///   birthday gift) leads in a filled circle.
/// - **Reminder** — no fill: a hollow circle in the list's colour and the title
///   in the ordinary label colour, the way an unticked reminder looks.
/// - **Completed reminder** — the same, faded back.
///
/// Titles are clipped, not ellipsised. A cell is ~50pt wide; an ellipsis would
/// eat a third of it and Calendar simply cuts the word.
class MonthEventChip extends StatelessWidget {
  const MonthEventChip({
    super.key,
    required this.event,
    required this.calendar,
  });

  final CalendarEvent event;
  final CalendarSource calendar;

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    final palette = EventPalette.of(calendar.color, brightness);
    final reminder = event.isReminder;

    final Widget? lead = reminder
        ? _ReminderRing(color: calendar.color)
        : calendar.badge == null
        ? null
        : _BadgeGlyph(color: calendar.color, glyph: calendar.badge!.glyph);

    Widget chip = Container(
      height: CalMetrics.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: reminder && !event.isCompleted
          ? null
          : ShapeDecoration(
              color: palette.fill,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(CalMetrics.chipRadius),
              ),
            ),
      child: Row(
        children: [
          if (lead != null) ...[lead, const SizedBox(width: 2)],
          Expanded(
            child: Text(
              _clipped(event.title),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: reminder ? CalColors.labelOf(context) : palette.ink,
                fontSize: CalMetrics.chipTextSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );

    if (reminder && event.isCompleted) {
      chip = Opacity(opacity: 0.4, child: chip);
    }
    return chip;
  }
}

class _ReminderRing extends StatelessWidget {
  const _ReminderRing({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CalMetrics.chipGlyphSize,
      height: CalMetrics.chipGlyphSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.3),
      ),
    );
  }
}

class _BadgeGlyph extends StatelessWidget {
  const _BadgeGlyph({required this.color, required this.glyph});

  final Color color;
  final IconData glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CalMetrics.chipGlyphSize,
      height: CalMetrics.chipGlyphSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(glyph, size: 7, color: CalColors.onAccent),
    );
  }
}

/// The title cut down to what a chip can ever show.
///
/// A day cell is ~52pt wide, room for about ten characters at 11pt, and the
/// text is clipped anyway — but shaping runs over the whole string first.
/// Cutting it here (by grapheme, so an emoji is never split) keeps every chip
/// a short paragraph however long the event's title is.
String _clipped(String title) {
  final chars = title.characters;
  return chars.length <= CalMetrics.chipMaxCharacters
      ? title
      : chars.take(CalMetrics.chipMaxCharacters).toString();
}
