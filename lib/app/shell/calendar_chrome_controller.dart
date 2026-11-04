import 'package:flutter/foundation.dart';

/// What the floating toolbar asks of whichever page is on screen.
///
/// The toolbar is drawn once, above the Navigator, so it cannot call into a
/// page directly — it does not know which page is showing. Instead it fires a
/// request here, and the page on top listens for the requests it can answer.
/// A pushed page that does not care simply never subscribes.
class CalendarChromeController {
  /// "Today" was tapped. Month scrolls to the current month, Day jumps to
  /// today, Year scrolls to this year.
  final todayRequests = CalendarPulse();

  /// "Calendars" was tapped.
  final calendarsRequests = CalendarPulse();

  /// "Inbox" was tapped.
  final inboxRequests = CalendarPulse();

  void dispose() {
    todayRequests.dispose();
    calendarsRequests.dispose();
    inboxRequests.dispose();
  }
}

/// A `Listenable` that carries no value — an event, not a state.
class CalendarPulse extends ChangeNotifier {
  void fire() => notifyListeners();
}
