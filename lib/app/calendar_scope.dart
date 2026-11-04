import 'package:flutter/widgets.dart';

import '../data/event_store.dart';
import 'shell/calendar_chrome_controller.dart';
import 'today_clock.dart';

/// Hands the app's long-lived objects down the tree.
///
/// Above the `CupertinoApp`, so a pushed route reaches the same instances as
/// the chrome floating over the Navigator. It only ever carries references and
/// never rebuilds: each object is a `Listenable`, and a widget that cares
/// about one listens to that one, so a new event does not rebuild the toolbar
/// and midnight does not rebuild the event store's readers twice.
class CalendarScope extends InheritedWidget {
  const CalendarScope({
    super.key,
    required this.store,
    required this.today,
    required this.chrome,
    required super.child,
  });

  final EventStore store;
  final TodayClock today;
  final CalendarChromeController chrome;

  static CalendarScope _of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CalendarScope>();
    assert(scope != null, 'No CalendarScope found above this widget.');
    return scope!;
  }

  static EventStore storeOf(BuildContext context) => _of(context).store;

  static TodayClock todayOf(BuildContext context) => _of(context).today;

  static CalendarChromeController chromeOf(BuildContext context) =>
      _of(context).chrome;

  /// The objects never change identity, so nothing ever needs notifying.
  @override
  bool updateShouldNotify(CalendarScope oldWidget) => false;
}
