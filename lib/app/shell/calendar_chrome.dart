import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../shared/widgets/glass_text_capsule.dart';
import '../calendar_scope.dart';
import '../theme/cal_colors.dart';
import '../theme/cal_glass.dart';
import '../theme/cal_metrics.dart';

/// The floating bottom toolbar — Today on the left, Calendars and Inbox on the
/// right — drawn once, above the Navigator.
///
/// ## Why above the Navigator
///
/// Calendar's toolbar does not move when you drill from Year to Month to Day:
/// the pages zoom and slide underneath it while it stays put. A toolbar owned
/// by each page would slide away with its page and a new one slide in. So the
/// toolbar sits here, in `CupertinoApp.builder`, and every route passes under
/// it. Pages leave [contentPadding] at their bottom so their last row clears
/// it.
///
/// The cost is that the toolbar does not know which page is showing, so it
/// talks to them through [CalendarScope.chromeOf] rather than by calling them.
class CalendarChrome extends StatelessWidget {
  const CalendarChrome({super.key, required this.child});

  final Widget child;

  /// How much a scrolling page must leave empty at its bottom to clear the
  /// toolbar.
  static double contentPadding(BuildContext context) =>
      CalMetrics.bottomToolbarExtent(MediaQuery.viewPaddingOf(context).bottom);

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: CalMetrics.bottomToolbarHorizontalInset,
          right: CalMetrics.bottomToolbarHorizontalInset,
          bottom: CalMetrics.bottomToolbarBottom(safeBottom),
          // What GlassScaffold does for its own bottom bar, done by hand
          // because this toolbar is not inside one: pin the tier, and keep the
          // glass from sampling other glass.
          child: GlassIsolationScope(
            defaultQuality: CalGlass.quality,
            // Two glass surfaces side by side over the same content: one
            // shared backdrop read instead of a full-screen copy each.
            child: GlassBackdropGroup(
              // Boundaried, so the buttons' press springs repaint only
              // themselves and never mark the page underneath dirty.
              child: RepaintBoundary(child: _Toolbar()),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chrome = CalendarScope.chromeOf(context);
    final ink = CalColors.labelOf(context);

    return Row(
      children: [
        GlassTextCapsule(label: 'Today', onTap: chrome.todayRequests.fire),
        const Spacer(),
        GlassButtonGroup.icons(
          items: [
            GlassButtonGroupItem(
              icon: Icon(CupertinoIcons.calendar, color: ink),
              label: 'Calendars',
              onTap: chrome.calendarsRequests.fire,
            ),
            GlassButtonGroupItem(
              icon: Icon(CupertinoIcons.tray, color: ink),
              label: 'Inbox',
              onTap: chrome.inboxRequests.fire,
            ),
          ],
          settings: CalGlass.settings(context),
          quality: CalGlass.quality,
          useOwnLayer: true,
          borderRadius: CalMetrics.minGlassControl / 2,
          iconSize: CalMetrics.barIconSize,
          // 62 × 48 per glyph: the pair reads as one wide capsule, as in the
          // reference, and neither slot drops under the 48pt minimum.
          itemPadding: const EdgeInsets.symmetric(
            horizontal:
                (CalMetrics.toolbarGroupItemWidth - CalMetrics.barIconSize) / 2,
            vertical: (CalMetrics.minGlassControl - CalMetrics.barIconSize) / 2,
          ),
        ),
      ],
    );
  }
}
