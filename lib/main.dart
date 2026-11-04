import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app/calendar_app.dart';
import 'app/calendar_scope.dart';
import 'app/shell/calendar_chrome_controller.dart';
import 'app/theme/cal_glass.dart';
import 'app/today_clock.dart';
import 'data/sample_calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Async disk-to-RAM shader preload: no GPU work, so the first frame is not
  // held back, and the first glass surface does not flash while compiling.
  await LiquidGlassWidgets.initialize();

  runApp(
    // Above the CupertinoApp, so the floating toolbar (built above the
    // Navigator) and every pushed route reach the same instances.
    CalendarScope(
      store: SampleCalendar.build(DateTime.now()),
      today: TodayClock(),
      chrome: CalendarChromeController(),
      child: LiquidGlassWidgets.wrap(
        // The iOS 27 `glassEffect(.regular)` material, premium in light and
        // dark. No adaptive quality: it benchmarks for a few seconds at launch
        // and can drop a tier mid-session, which on chrome that is always on
        // screen reads as the app degrading — and the brief is premium always.
        theme: CalGlass.theme,
        child: const CalendarApp(),
      ),
    ),
  );
}
