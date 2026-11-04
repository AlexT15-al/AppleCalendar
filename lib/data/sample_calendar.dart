import '../domain/calendar_event.dart';
import '../domain/calendar_source.dart';
import '../shared/calendar_date.dart';
import 'event_store.dart';

/// A believable calendar to develop the UI against, until real events come
/// from the user and from the device.
///
/// Built relative to today, so every screen has content wherever the app is
/// opened. Deterministic — no randomness — so a layout bug reproduces on the
/// next launch instead of moving to another day.
abstract final class SampleCalendar {
  static const home = CalendarSource(
    id: 'home',
    title: 'Home',
    color: CalendarSwatch.blue,
  );
  static const work = CalendarSource(
    id: 'work',
    title: 'Work',
    color: CalendarSwatch.red,
  );
  static const family = CalendarSource(
    id: 'family',
    title: 'Family',
    color: CalendarSwatch.green,
  );
  static const fitness = CalendarSource(
    id: 'fitness',
    title: 'Fitness',
    color: CalendarSwatch.orange,
  );
  static const music = CalendarSource(
    id: 'music',
    title: 'Music',
    color: CalendarSwatch.yellow,
  );
  static const holidays = CalendarSource(
    id: 'holidays',
    title: 'US Holidays',
    color: CalendarSwatch.blue,
    badge: CalendarBadge.star,
  );
  static const birthdays = CalendarSource(
    id: 'birthdays',
    title: 'Birthdays',
    color: CalendarSwatch.grey,
    badge: CalendarBadge.gift,
  );
  static const reminders = CalendarSource(
    id: 'reminders',
    title: 'Reminders',
    color: CalendarSwatch.purple,
    isReminderList: true,
  );

  static EventStore build(DateTime now) {
    final today = CalendarDate.dateOnly(now);
    final events = <CalendarEvent>[];
    var seq = 0;
    String id() => 'sample-${seq++}';

    void timed(
      CalendarSource cal,
      String title,
      DateTime day,
      int hour,
      int minutes, {
      int durationMinutes = 60,
      String? location,
    }) {
      final start = DateTime(day.year, day.month, day.day, hour, minutes);
      events.add(
        CalendarEvent(
          id: id(),
          title: title,
          calendarId: cal.id,
          start: start,
          end: start.add(Duration(minutes: durationMinutes)),
          location: location,
        ),
      );
    }

    void allDay(
      CalendarSource cal,
      String title,
      DateTime day, {
      int days = 1,
    }) {
      events.add(
        CalendarEvent(
          id: id(),
          title: title,
          calendarId: cal.id,
          start: day,
          end: CalendarDate.addDays(day, days),
          isAllDay: true,
        ),
      );
    }

    void reminder(String title, DateTime day, int hour) {
      final at = DateTime(day.year, day.month, day.day, hour);
      events.add(
        CalendarEvent(
          id: id(),
          title: title,
          calendarId: reminders.id,
          start: at,
          end: at,
          kind: EntryKind.reminder,
          // Anything already past is ticked off, the way a real list looks.
          isCompleted: at.isBefore(now),
        ),
      );
    }

    // Four months either side of today, which is plenty to scroll through.
    final first = CalendarDate.monthIndex(today) - 4;
    final last = CalendarDate.monthIndex(today) + 4;
    final from = CalendarDate.monthStart(first);
    final to = CalendarDate.monthStart(last + 1);

    for (var day = from; day.isBefore(to); day = CalendarDate.addDays(day, 1)) {
      switch (day.weekday) {
        case DateTime.monday:
          timed(work, 'Portfolio review', day, 10, 0);
          reminder('FaceTime Grandma', day, 18);
        case DateTime.tuesday:
          timed(
            home,
            'Meet Orla for lunch',
            day,
            12,
            30,
            location: 'Blue Bottle Coffee',
          );
          timed(work, 'Art workshop', day, 15, 0, durationMinutes: 90);
        case DateTime.wednesday:
          timed(family, 'FaceTime with Mum', day, 19, 0, durationMinutes: 30);
          timed(work, 'Portfolio critique', day, 16, 0);
        case DateTime.thursday:
          reminder('Take out recycling', day, 8);
          timed(fitness, '🏋️ Stretching class', day, 7, 0);
        case DateTime.friday:
          reminder('Weekly review', day, 17);
          timed(work, 'Weekly sync', day, 9, 30, durationMinutes: 30);
        case DateTime.saturday:
          timed(home, 'Hike with Sam', day, 9, 0, durationMinutes: 180);
          timed(family, 'Family dinner', day, 19, 0, durationMinutes: 120);
        case DateTime.sunday:
          timed(music, '🎸 Guitar lesson', day, 11, 0);
      }
      // A busier day every so often, so "+N" overflow shows up.
      if (day.day % 9 == 0) {
        timed(work, 'Design review', day, 14, 0);
        timed(home, 'Dentist', day, 8, 30, durationMinutes: 45);
        reminder('Pay rent', day, 9);
      }
    }

    // Holidays and birthdays on their real dates, for every year in range.
    for (var year = from.year; year <= to.year; year++) {
      allDay(holidays, "New Year's Day", DateTime(year, 1, 1));
      allDay(holidays, "Valentine's Day", DateTime(year, 2, 14));
      allDay(holidays, "St. Patrick's Day", DateTime(year, 3, 17));
      allDay(holidays, 'Tax Day', DateTime(year, 4, 15));
      allDay(holidays, 'Earth Day', DateTime(year, 4, 22));
      allDay(holidays, 'Independence Day', DateTime(year, 7, 4));
      allDay(holidays, 'Halloween', DateTime(year, 10, 31));
      allDay(holidays, 'Veterans Day', DateTime(year, 11, 11));
      allDay(
        holidays,
        'Thanksgiving',
        _nthWeekday(year, 11, DateTime.thursday, 4),
      );
      allDay(holidays, 'Christmas Eve', DateTime(year, 12, 24));
      allDay(holidays, 'Christmas Day', DateTime(year, 12, 25));
      allDay(
        holidays,
        "Mother's Day",
        _nthWeekday(year, 5, DateTime.sunday, 2),
      );
      allDay(holidays, 'Labor Day', _nthWeekday(year, 9, DateTime.monday, 1));
      allDay(birthdays, "Brian's Birthday", DateTime(year, 4, 10));
      allDay(birthdays, "Danny's Birthday", DateTime(year, 4, 22));
      allDay(birthdays, "Elena's Birthday", DateTime(year, 11, 18));
      allDay(birthdays, "Sam's Birthday", DateTime(year, 1, 27));
    }

    // Something on today and tomorrow, so the first screen is never empty.
    timed(work, 'Interview — Product Designer', today, 15, 0);
    allDay(home, 'Book club', CalendarDate.addDays(today, 1));
    allDay(family, 'Rainbow trip', CalendarDate.addDays(today, 8), days: 3);

    return EventStore(
      calendars: const [
        home,
        work,
        family,
        fitness,
        music,
        holidays,
        birthdays,
        reminders,
      ],
      events: events,
    );
  }

  static DateTime _nthWeekday(int year, int month, int weekday, int n) {
    final first = DateTime(year, month);
    final offset = (weekday - first.weekday) % 7;
    return DateTime(year, month, 1 + offset + (n - 1) * 7);
  }
}
