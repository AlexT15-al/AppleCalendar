import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../app/calendar_scope.dart';
import '../../app/shell/calendar_chrome_controller.dart';
import '../../app/theme/cal_colors.dart';
import '../../app/theme/cal_glass.dart';
import '../../app/theme/cal_metrics.dart';
import '../../app/theme/cal_motion.dart';
import '../../data/event_store.dart';
import '../../shared/calendar_date.dart';
import '../../shared/widgets/transparent_system_bars.dart';
import 'month_density.dart';
import 'month_layout.dart';
import 'widgets/month_header.dart';
import 'widgets/month_rows.dart';

/// Month view — the screen Calendar opens on.
///
/// An endless vertical run of months under a sticky header that names the
/// month in view. Reference: `reference/ios26_month_details_light.png`.
class MonthPage extends StatefulWidget {
  const MonthPage({super.key});

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage>
    with SingleTickerProviderStateMixin {
  static const _centerKey = ValueKey('month-grid-center');

  /// The month at scroll offset 0. Fixed for the life of the page: moving it
  /// would shift every offset under the user's finger.
  late final int _anchor = CalendarDate.monthIndex(
    CalendarScope.todayOf(context).value,
  );

  late ScrollController _scroll;
  bool _scrollReady = false;

  MonthDensity _density = MonthDensity.details;
  late double _rowHeight = _density.rowHeight;

  /// Drives the row height between two densities.
  late final AnimationController _resize = AnimationController(
    vsync: this,
    duration: CalMotion.densitySwapDuration,
  )..addListener(_onResizeTick);
  double _resizeFrom = MonthDensity.details.rowHeight;
  double _resizeTo = MonthDensity.details.rowHeight;

  /// Which month the resize keeps in place, and where in it the top of the
  /// visible grid was: inside the label row (in points, since the label row
  /// does not resize) or so many week rows into the month (in rows, since
  /// they do).
  int _pinnedMonth = 0;
  double? _pinnedLabelPoints;
  double _pinnedWeeks = 0;

  late MonthLayout _layout = _buildLayout();

  /// The month named in the sticky header.
  late final ValueNotifier<int> _visibleMonth = ValueNotifier(_anchor);

  /// The year named in the back capsule. Separate from [_visibleMonth] so the
  /// navigation bar — whose pinned items re-register with the shell whenever
  /// it rebuilds — rebuilds once a year of scrolling, not once a month.
  late final ValueNotifier<int> _visibleYear = ValueNotifier(
    CalendarDate.monthStart(_anchor).year,
  );

  int _firstWeekday = DateTime.sunday;

  /// Held, not looked up again in [dispose]: an inherited lookup from a
  /// deactivated element is not allowed.
  late CalendarChromeController _chrome;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MaterialLocalizations is the only place Flutter keeps the locale's first
    // day of the week (0 = Sunday). The delegate is installed on the app, so
    // this follows the device rather than assuming the US.
    final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final weekday = index == 0 ? DateTime.sunday : index;
    if (weekday != _firstWeekday) {
      _firstWeekday = weekday;
      _layout = _buildLayout();
    }

    if (!_scrollReady) {
      _scrollReady = true;
      // Opens with the anchor month's first week sitting right under the
      // header, its label row tucked away beneath it — as Calendar opens.
      _scroll = ScrollController(
        initialScrollOffset: _layout.firstWeekTopOf(_anchor) - _headerBottom,
      )..addListener(_onScroll);
      _chrome = CalendarScope.chromeOf(context)
        ..todayRequests.addListener(_scrollToToday);
    }
  }

  @override
  void dispose() {
    _chrome.todayRequests.removeListener(_scrollToToday);
    _scroll.dispose();
    _resize.dispose();
    _visibleMonth.dispose();
    _visibleYear.dispose();
    super.dispose();
  }

  MonthLayout _buildLayout() => MonthLayout(
    anchor: _anchor,
    rowHeight: _rowHeight,
    firstWeekday: _firstWeekday,
  );

  /// Status bar + navigation bar + month header: the bottom edge of the
  /// sticky chrome, in screen coordinates — and so in scroll coordinates too,
  /// since the grid runs under all of it from the top of the screen.
  double get _headerBottom =>
      MediaQuery.paddingOf(context).top +
      CalMetrics.toolbarHeight +
      CalMetrics.monthHeaderExtent;

  /// Content offset just under the header, where the header reads its month.
  double get _probe => _scroll.offset + _headerBottom + 1;

  void _onScroll() {
    final month = _layout.monthAt(_probe);
    if (month == _visibleMonth.value) return;
    _visibleMonth.value = month;
    _visibleYear.value = CalendarDate.monthStart(month).year;
  }

  // ── Today ──────────────────────────────────────────────────────────────────

  void _scrollToToday() {
    if (!_scroll.hasClients) return;
    final todayMonth = CalendarDate.monthIndex(
      CalendarScope.todayOf(context).value,
    );
    final target = _layout.firstWeekTopOf(todayMonth) - _headerBottom;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final distance = todayMonth - _visibleMonth.value;
    if (reduceMotion) {
      _scroll.jumpTo(target);
      return;
    }
    // From far away, jump to a few months short and animate only that last
    // stretch: the motion still says "this way", without a blur of years.
    if (distance.abs() > CalMotion.scrollToMaxAnimatedMonths) {
      final from =
          todayMonth - distance.sign * CalMotion.scrollToMaxAnimatedMonths;
      _scroll.jumpTo(_layout.firstWeekTopOf(from) - _headerBottom);
    }
    _scroll.animateTo(
      target,
      duration: CalMotion.scrollToDuration,
      curve: CalMotion.scrollToCurve,
    );
  }

  // ── Density ────────────────────────────────────────────────────────────────

  void _setDensity(MonthDensity density) {
    if (density == _density) return;
    HapticFeedback.selectionClick();

    // Remember what is under the header now, so the resize grows the grid
    // around it instead of letting it slide away.
    _pinnedMonth = _layout.monthAt(_probe);
    final local = _probe - _layout.topOf(_pinnedMonth);
    if (local < CalMetrics.monthLabelRowHeight) {
      _pinnedLabelPoints = local;
    } else {
      _pinnedLabelPoints = null;
      _pinnedWeeks = (local - CalMetrics.monthLabelRowHeight) / _rowHeight;
    }

    setState(() => _density = density);
    _resizeFrom = _rowHeight;
    _resizeTo = density.rowHeight;

    if (MediaQuery.disableAnimationsOf(context)) {
      _applyRowHeight(_resizeTo);
      return;
    }
    _resize.forward(from: 0);
  }

  void _onResizeTick() {
    final t = CalMotion.standardCurve.transform(_resize.value);
    _applyRowHeight(lerpDouble(_resizeFrom, _resizeTo, t)!);
  }

  void _applyRowHeight(double height) {
    _rowHeight = height;
    _layout = _buildLayout();
    // The same point of the same month, at the new row height — so the week
    // under the header stays under the header while every row grows.
    final probe =
        _layout.topOf(_pinnedMonth) +
        (_pinnedLabelPoints ??
            CalMetrics.monthLabelRowHeight + _pinnedWeeks * height);
    if (_scroll.hasClients) _scroll.jumpTo(probe - _headerBottom - 1);
    setState(() {});
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final store = CalendarScope.storeOf(context);
    final todayClock = CalendarScope.todayOf(context);
    final topInset =
        MediaQuery.paddingOf(context).top + CalMetrics.toolbarHeight;
    final page = CalColors.background.resolveFrom(context);

    // The grid is built once here and handed to the builder below as its
    // child, so a year change in the bar never rebuilds 35 cells a month.
    final grid = ListenableBuilder(
      listenable: Listenable.merge([store, todayClock]),
      builder: (context, _) => _grid(store, todayClock.value),
    );

    final header = Positioned(
      top: 0,
      left: 0,
      right: 0,
      // Its own layer: the title cross-fade repaints the header and nothing
      // under it.
      child: RepaintBoundary(
        child: ListenableBuilder(
          listenable: Listenable.merge([_visibleMonth, todayClock]),
          builder: (context, _) => MonthHeader(
            month: _visibleMonth.value,
            today: todayClock.value,
            firstWeekday: _firstWeekday,
            topInset: topInset,
          ),
        ),
      ),
    );

    return TransparentSystemBars(
      child: ValueListenableBuilder<int>(
        valueListenable: _visibleYear,
        builder: (context, year, grid) => GlassScaffold(
          background: ColoredBox(color: page),
          backgroundColor: page,
          // A flat page colour: sampling it into a texture for the glass to
          // absorb teaches the shader nothing and costs a capture per frame.
          enableBackgroundSampling: false,
          statusBarStyle: GlassStatusBarStyle.none,
          resizeToAvoidBottomInset: false,
          // `soft`, not `blur`. The progressive blur is a two-pass gaussian
          // over the live grid, re-run on every frame of a scroll across
          // ~190pt at the top and ~100pt at the bottom — on top of the premium
          // glass already reading the backdrop there. The soft fade is iOS's
          // default edge style and costs a gradient.
          edgeStyle: GlassScrollEdgeStyle.soft,
          // The fade has to reach the bottom of the sticky month header, not
          // just the bar.
          appBarHeight: CalMetrics.toolbarHeight + CalMetrics.monthHeaderExtent,
          topEdgeFadeExtent: 8,
          topEdgeFade: true,
          // Under the floating toolbar, which the scaffold does not know about.
          bottomEdgeFade: true,
          bottomEdgeFadeExtent: CalMetrics.minGlassControl + 24,
          appBar: _appBar(context, year),
          bodyOverlays: [header],
          body: grid!,
        ),
        child: grid,
      ),
    );
  }

  Widget _grid(EventStore store, DateTime today) {
    final layout = _layout;

    Widget row(MonthRow row) {
      final week = row.week;
      if (week == null) {
        return MonthLabelRow(
          month: row.month,
          firstWeekday: _firstWeekday,
          today: today,
        );
      }
      return MonthWeekRow(
        month: row.month,
        week: week,
        rowHeight: _rowHeight,
        firstWeekday: _firstWeekday,
        today: today,
        store: store,
        // Day view lands next; until then a tap is a no-op rather than a
        // half-built screen.
      );
    }

    // Varied-extent lists rather than plain ones: every row's height is known
    // up front, so the list positions rows by arithmetic instead of laying out
    // everything between here and a jump target, and Today can land far away
    // without building the months in between.
    return CustomScrollView(
      controller: _scroll,
      center: _centerKey,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        // Before the anchor month. A sliver before `center` grows upward, so
        // its index 0 is the last week of the previous month.
        SliverVariedExtentList.builder(
          itemExtentBuilder: (i, _) => layout.extentOf(layout.backwardRow(i)),
          itemBuilder: (context, i) => row(layout.backwardRow(i)),
        ),
        SliverVariedExtentList.builder(
          key: _centerKey,
          itemExtentBuilder: (i, _) => layout.extentOf(layout.forwardRow(i)),
          itemBuilder: (context, i) => row(layout.forwardRow(i)),
        ),
      ],
    );
  }

  GlassAppBar _appBar(BuildContext context, int year) {
    final ink = CalColors.labelOf(context);

    return GlassAppBar.pinned(
      toolbarHeight: CalMetrics.toolbarHeight,
      buttonSize: CalMetrics.minGlassControl,
      padding: const EdgeInsets.symmetric(horizontal: CalMetrics.navBarPadding),
      buttonSettings: CalGlass.settings(context),
      // Month is the root for now; Year view lands underneath it next, and
      // this capsule becomes the way back to it.
      backButton: false,
      leading: [
        GlassBarItem.custom(
          id: 'nav-back',
          label: '$year',
          background: GlassBarItemBackground.separate,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.back, color: ink, size: 22),
                const SizedBox(width: 2),
                Text(
                  '$year',
                  style: TextStyle(
                    color: ink,
                    fontSize: CalMetrics.barTextSize,
                    letterSpacing: -0.41,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      actions: [
        GlassBarItem.menu(
          id: 'view-mode',
          label: 'View Options',
          icon: Icon(CupertinoIcons.rectangle_grid_1x2, color: ink),
          background: GlassBarItemBackground.separate,
          menuWidth: 220,
          menuSettings: CalGlass.settings(context),
          menuItems: [
            for (final density in MonthDensity.values)
              _menuItem(
                context,
                density.label,
                density == _density,
                () => _setDensity(density),
              ),
          ],
        ),
        GlassBarItem.icon(
          id: 'search',
          label: 'Search',
          icon: Icon(CupertinoIcons.search, color: ink),
          onTap: () {},
        ),
        GlassBarItem.icon(
          id: 'add',
          label: 'Add Event',
          icon: Icon(CupertinoIcons.add, color: ink),
          onTap: () {},
        ),
      ],
    );
  }

  GlassMenuItem _menuItem(
    BuildContext context,
    String title,
    bool selected,
    VoidCallback onTap,
  ) {
    final ink = CalColors.labelOf(context);
    return GlassMenuItem(
      title: title,
      // The checkmark leads, as in every iOS 26 selection menu; unselected rows
      // keep an empty slot so the titles stay aligned.
      icon: selected
          ? const Icon(CupertinoIcons.checkmark)
          : const SizedBox.square(dimension: 20),
      iconColor: ink,
      titleStyle: TextStyle(color: ink, fontSize: 17, letterSpacing: -0.41),
      height: 48,
      isSelected: selected,
      onTap: onTap,
    );
  }
}
