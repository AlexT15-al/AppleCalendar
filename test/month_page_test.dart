import 'package:apple_calendar/app/calendar_app.dart';
import 'package:apple_calendar/app/calendar_scope.dart';
import 'package:apple_calendar/app/shell/calendar_chrome_controller.dart';
import 'package:apple_calendar/app/theme/cal_glass.dart';
import 'package:apple_calendar/app/today_clock.dart';
import 'package:apple_calendar/data/sample_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Widget _app(TodayClock clock) => CalendarScope(
  store: SampleCalendar.build(DateTime.now()),
  today: clock,
  chrome: CalendarChromeController(),
  child: LiquidGlassWidgets.wrap(
    theme: CalGlass.theme,
    child: const CalendarApp(),
  ),
);

void main() {
  testWidgets('Month view builds, scrolls and answers Today', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 177, bottom: 102);
    addTearDown(tester.view.reset);

    final clock = TodayClock();
    await tester.pumpWidget(_app(clock));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Today'), findsOneWidget);

    // Scroll a long way, then come back with Today.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);

    // The clock arms a timer for midnight; the test owns it, so it ends it.
    await tester.pumpWidget(const SizedBox.shrink());
    clock.dispose();
  });
}
