import 'package:flutter/cupertino.dart';

/// The glyph a subscribed calendar stamps on its events — the star on a
/// holiday, the gift on a birthday — drawn in a filled circle at the start of
/// the event's chip.
enum CalendarBadge {
  star(CupertinoIcons.star_fill),
  gift(CupertinoIcons.gift_fill);

  const CalendarBadge(this.glyph);

  final IconData glyph;
}

/// One calendar: "Home", "Work", "US Holidays", a Reminders list.
@immutable
class CalendarSource {
  const CalendarSource({
    required this.id,
    required this.title,
    required this.color,
    this.badge,
    this.isReminderList = false,
  });

  final String id;
  final String title;

  /// The calendar's colour, exactly as the user picked it. Chips derive their
  /// tinted fill and their text ink from it; see `EventPalette`.
  final Color color;

  /// Set on subscribed calendars whose events carry a glyph.
  final CalendarBadge? badge;

  /// A Reminders list shown in Calendar (iOS 18+). Its items draw as a hollow
  /// circle and a plain label rather than as a tinted chip.
  final bool isReminderList;

  @override
  bool operator ==(Object other) => other is CalendarSource && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Apple Calendar's own colour swatches — the seven offered when creating a
/// calendar in iCloud. These are the calendar colours, not the system colours;
/// Calendar's blue is a lighter, cooler blue than systemBlue.
abstract final class CalendarSwatch {
  static const red = Color(0xFFFF2968);
  static const orange = Color(0xFFFF9500);
  static const yellow = Color(0xFFFFCC00);
  static const green = Color(0xFF63DA38);
  static const blue = Color(0xFF1BADF8);
  static const purple = Color(0xFFCC73E1);
  static const brown = Color(0xFFA2845E);

  /// Birthdays is grey in Calendar.
  static const grey = Color(0xFF8E8E93);
}
