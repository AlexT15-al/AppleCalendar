import 'package:flutter/foundation.dart';

import '../domain/calendar_event.dart';
import '../domain/calendar_source.dart';
import '../shared/calendar_date.dart';

/// The calendars and everything on them.
///
/// In memory for now; persistence lands with event creation. Screens never read
/// [events] directly — they ask for a day with [eventsOn], which is answered
/// from a per-day index so a month grid of 42 cells costs 42 map lookups per
/// build rather than 42 scans of every event.
class EventStore extends ChangeNotifier {
  EventStore({
    required List<CalendarSource> calendars,
    required List<CalendarEvent> events,
  }) : _calendars = {for (final c in calendars) c.id: c},
       _events = List.of(events);

  final Map<String, CalendarSource> _calendars;
  final List<CalendarEvent> _events;

  /// Day key → that day's entries, already sorted. Built lazily, one day at a
  /// time, and thrown away whenever anything changes.
  final Map<int, List<CalendarEvent>> _byDay = {};

  /// Calendars switched off in the Calendars sheet.
  final Set<String> _hidden = {};

  Iterable<CalendarSource> get calendars => _calendars.values;

  CalendarSource calendarOf(CalendarEvent event) =>
      _calendars[event.calendarId]!;

  bool isVisible(CalendarSource calendar) => !_hidden.contains(calendar.id);

  void setVisible(CalendarSource calendar, bool visible) {
    final changed = visible
        ? _hidden.remove(calendar.id)
        : _hidden.add(calendar.id);
    if (changed) _invalidate();
  }

  void add(CalendarEvent event) {
    _events.add(event);
    _invalidate();
  }

  void update(CalendarEvent event) {
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i < 0) return;
    _events[i] = event;
    _invalidate();
  }

  void remove(String id) {
    _events.removeWhere((e) => e.id == id);
    _invalidate();
  }

  void _invalidate() {
    _byDay.clear();
    notifyListeners();
  }

  /// Everything visible on [day], in the order Calendar lists it: all-day
  /// entries first, then by start time, ties broken by title so the order is
  /// stable across rebuilds.
  List<CalendarEvent> eventsOn(DateTime day) {
    final key = CalendarDate.dayKey(day);
    return _byDay[key] ??= _collect(CalendarDate.dateOnly(day));
  }

  List<CalendarEvent> _collect(DateTime dayStart) {
    final dayEnd = CalendarDate.addDays(dayStart, 1);
    final result = [
      for (final e in _events)
        if (!_hidden.contains(e.calendarId) &&
            e.start.isBefore(dayEnd) &&
            // A timed event ending exactly at midnight does not spill into the
            // next day; a zero-length one (a reminder) still belongs to its day.
            (e.end.isAfter(dayStart) ||
                (e.start == e.end && !e.start.isBefore(dayStart))))
          e,
    ];
    result.sort((a, b) {
      if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
      final byTime = a.start.compareTo(b.start);
      return byTime != 0 ? byTime : a.title.compareTo(b.title);
    });
    return List.unmodifiable(result);
  }
}
