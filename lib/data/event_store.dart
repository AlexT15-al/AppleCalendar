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

  /// Day key → that day's entries, already sorted. Built on first use and
  /// thrown away whenever anything changes.
  Map<int, List<CalendarEvent>>? _index;

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
    _index = null;
    notifyListeners();
  }

  /// Everything visible on [day], in the order Calendar lists it: all-day
  /// entries first, then by start time, ties broken by title so the order is
  /// stable across rebuilds.
  List<CalendarEvent> eventsOn(DateTime day) =>
      (_index ??= _buildIndex())[CalendarDate.dayKey(day)] ?? const [];

  /// One pass over every event, dropping each into the days it covers.
  ///
  /// Built once per change rather than per day asked for: a month grid asks
  /// for ~35 days at a time while scrolling, and scanning the whole event list
  /// for each of them is the kind of cost that lands on exactly the frames
  /// where a new month scrolls into view.
  Map<int, List<CalendarEvent>> _buildIndex() {
    final index = <int, List<CalendarEvent>>{};
    for (final e in _events) {
      if (_hidden.contains(e.calendarId)) continue;
      var day = CalendarDate.dateOnly(e.start);
      // A zero-length entry (a reminder) belongs to its day. Anything else
      // covers every day it overlaps — and a timed event ending exactly at
      // midnight does not spill into the next one.
      do {
        (index[CalendarDate.dayKey(day)] ??= []).add(e);
        day = CalendarDate.addDays(day, 1);
      } while (day.isBefore(e.end));
    }
    for (final list in index.values) {
      list.sort(_byCalendarOrder);
    }
    return index;
  }

  static int _byCalendarOrder(CalendarEvent a, CalendarEvent b) {
    if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
    final byTime = a.start.compareTo(b.start);
    return byTime != 0 ? byTime : a.title.compareTo(b.title);
  }
}
