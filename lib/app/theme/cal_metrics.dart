/// Every layout constant in the app.
///
/// Measured off `reference/ios26_month_details_light.png` (a 393pt-wide
/// iPhone frame, ~1.13 px per point) unless noted. Treat them as first
/// approximations to correct against further references, not as measured
/// truth — which is exactly why they live in one place.
abstract final class CalMetrics {
  // ── Glass controls ─────────────────────────────────────────────────────────

  /// The smallest any glass control is allowed to be, in either axis.
  ///
  /// A project rule, and deliberately above iOS 26's own 44pt bar buttons:
  /// every liquid button, capsule and group is at least 48×48.
  static const double minGlassControl = 48.0;

  /// Height of the navigation bar the pinned chrome sits in. Room for a 48pt
  /// button with 4pt above and below.
  static const double toolbarHeight = 56.0;

  /// Inset of the navigation bar's capsules from the screen edges.
  static const double navBarPadding = 16.0;

  /// Icon size inside bar buttons and toolbar groups.
  static const double barIconSize = 22.0;

  /// Label size of text bar buttons ("Today", the year back button).
  static const double barTextSize = 17.0;

  /// Horizontal padding inside a text capsule.
  static const double textCapsulePadding = 20.0;

  // ── Bottom toolbar ─────────────────────────────────────────────────────────

  /// Inset of the bottom toolbar from the screen edges. Wider than the top
  /// bar's, because the toolbar sits down in the display's rounded corners.
  static const double bottomToolbarHorizontalInset = 26.0;

  /// How far the toolbar sinks into the home-indicator safe area. iOS 26 floats
  /// the toolbar over the indicator rather than above it.
  static const double bottomToolbarSafeAreaOverlap = 16.0;

  /// Minimum gap between the toolbar and the bottom edge on devices with no
  /// home indicator.
  static const double bottomToolbarMinBottom = 12.0;

  /// Width of one icon slot in the Calendars / Inbox group — 62pt per glyph in
  /// the reference, so the pair reads as one wide capsule.
  static const double toolbarGroupItemWidth = 62.0;

  /// Space the floating toolbar takes from the bottom of a page, so the last
  /// row of a scrolling view can clear it.
  static double bottomToolbarExtent(double safeBottom) =>
      minGlassControl + bottomToolbarBottom(safeBottom) + 12.0;

  static double bottomToolbarBottom(double safeBottom) {
    final sunk = safeBottom - bottomToolbarSafeAreaOverlap;
    return sunk > bottomToolbarMinBottom ? sunk : bottomToolbarMinBottom;
  }

  // ── Month header ───────────────────────────────────────────────────────────

  /// The sticky "April" title under the bar: 34pt bold, the iOS large title.
  static const double monthTitleSize = 34.0;
  static const double monthTitleTracking = 0.37;
  static const double monthTitleRowHeight = 50.0;

  /// The S M T W T F S row.
  static const double weekdayRowHeight = 24.0;
  static const double weekdayLetterSize = 11.0;

  /// Leading inset of the month title.
  static const double pagePadding = 20.0;

  /// Height of everything the month header draws below the navigation bar.
  static const double monthHeaderExtent =
      monthTitleRowHeight + weekdayRowHeight;

  // ── Month grid ─────────────────────────────────────────────────────────────

  /// The row above a month's first week carrying its name, aligned to the
  /// column of its first day ("May" at the bottom of the reference).
  static const double monthLabelRowHeight = 30.0;
  static const double monthLabelSize = 20.0;

  /// The day number, and the red circle behind today's.
  static const double dayNumberSize = 20.0;
  static const double dayCircleSize = 34.0;
  static const double dayNumberTop = 6.0;

  /// Where a day's events start, from the top of its week row.
  static const double dayContentTop = 46.0;

  static const double hairline = 0.33;

  /// Week-row height per month density. Details is measured; Compact and
  /// Stacked are estimates until there is a reference for them.
  static const double weekRowCompact = 68.0;
  static const double weekRowStacked = 86.0;
  static const double weekRowDetails = 119.0;

  // ── Event chips (Details density) ──────────────────────────────────────────

  static const double chipHeight = 17.0;
  static const double chipGap = 3.0;
  static const double chipRadius = 5.0;
  static const double chipHorizontalInset = 2.0;
  static const double chipTextSize = 11.0;

  /// More than a chip can show at its widest (a landscape cell), so cutting a
  /// title to this never changes what is drawn.
  static const int chipMaxCharacters = 18;
  static const double chipGlyphSize = 11.0;

  /// The "+7" under a day whose events do not all fit.
  static const double overflowTextSize = 10.0;
  static const double overflowRowHeight = 14.0;

  // ── Stacked density ────────────────────────────────────────────────────────

  static const double stackedBarHeight = 4.0;
  static const double stackedBarGap = 2.0;
  static const int stackedMaxBars = 4;

  // ── Compact density ────────────────────────────────────────────────────────

  static const double compactDotSize = 6.0;
}
