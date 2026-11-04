import 'package:flutter/foundation.dart';

/// Whether an entry is a calendar event or a reminder shown in Calendar.
enum EntryKind { event, reminder }

/// One entry on the calendar.
///
/// Times are local wall-clock [DateTime]s. An all-day entry's [start] is the
/// first day at midnight and its [end] is the *exclusive* midnight after the
/// last day — the same convention EventKit uses — so a one-day all-day event
/// spans exactly 24 hours and multi-day ranges need no special casing.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.calendarId,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.kind = EntryKind.event,
    this.isCompleted = false,
    this.location,
    this.notes,
  });

  final String id;
  final String title;
  final String calendarId;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;
  final EntryKind kind;

  /// Reminders only. A completed reminder stays on the calendar, faded.
  final bool isCompleted;

  final String? location;
  final String? notes;

  bool get isReminder => kind == EntryKind.reminder;

  CalendarEvent copyWith({
    String? title,
    String? calendarId,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    bool? isCompleted,
    String? location,
    String? notes,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      calendarId: calendarId ?? this.calendarId,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      kind: kind,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }
}
