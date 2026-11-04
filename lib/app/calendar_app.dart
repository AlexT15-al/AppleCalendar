import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../features/month/month_page.dart';
import 'shell/calendar_chrome.dart';
import 'theme/cal_colors.dart';

/// Root of the app.
///
/// [CupertinoApp] rather than `MaterialApp`: the glass package is Material-free
/// by design, and under `MaterialApp` every `Text` would need a `Material`
/// ancestor. The Material localizations delegate is still installed — it is
/// where Flutter keeps the locale's first day of the week — but nothing here
/// renders a Material widget.
///
/// No `brightness` on the theme: Calendar follows the system appearance.
class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Calendar',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(primaryColor: CalColors.accent),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('en', 'GB')],
      // The nesting order is load-bearing.
      //
      // `GlassNavigationShell` hoists each page's `GlassAppBar.pinned` items
      // above the Navigator so they morph across pushes — the "‹ 2026" capsule
      // becoming "‹ April" — instead of sliding away with their page. It must
      // wrap the Navigator, and there must be exactly one.
      //
      // `CalendarChrome` (the floating bottom toolbar) goes outside it, so the
      // toolbar stays put while Year, Month and Day move underneath.
      builder: (context, child) =>
          CalendarChrome(child: GlassNavigationShell(child: child!)),
      home: const MonthPage(),
    );
  }
}
