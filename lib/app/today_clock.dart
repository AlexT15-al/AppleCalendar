import 'dart:async';

import 'package:flutter/widgets.dart';

import '../shared/calendar_date.dart';

/// Today's date, kept current.
///
/// A calendar left open overnight must move its red circle at midnight, and
/// one brought back from the background after a day must not still show
/// yesterday. So this re-arms a timer for the next midnight, and re-checks
/// whenever the app resumes — a suspended app's timer does not fire on time.
///
/// Only the *date* is published. Listeners rebuild once a day, not once a
/// minute; the current-time line in Day view keeps its own finer clock.
class TodayClock extends ValueNotifier<DateTime> with WidgetsBindingObserver {
  TodayClock() : super(CalendarDate.dateOnly(DateTime.now())) {
    WidgetsBinding.instance.addObserver(this);
    _arm();
  }

  Timer? _timer;

  void _arm() {
    _timer?.cancel();
    final now = DateTime.now();
    final midnight = CalendarDate.addDays(CalendarDate.dateOnly(now), 1);
    // A second past midnight, so the refresh never lands a hair before it.
    _timer = Timer(
      midnight.difference(now) + const Duration(seconds: 1),
      _tick,
    );
  }

  void _tick() {
    final today = CalendarDate.dateOnly(DateTime.now());
    if (today != value) value = today;
    _arm();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
