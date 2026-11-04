import 'package:flutter/cupertino.dart';

/// Colour tokens for the Calendar clone.
///
/// Nothing in a widget hardcodes a colour. Every value is either an iOS system
/// colour or one measured off the reference screenshots in `reference/`, so a
/// correction lands here once.
abstract final class CalColors {
  // ── Surfaces ───────────────────────────────────────────────────────────────

  /// The page behind every calendar view.
  ///
  /// systemBackground, not systemGroupedBackground: Calendar's month, day and
  /// year grids sit on plain white / black (see
  /// `reference/ios26_month_details_light.png`). Grouped grey is only for the
  /// event forms.
  static const background = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF000000),
  );

  /// systemGroupedBackground — behind the event details and event forms.
  static const groupedBackground = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F2F7),
    darkColor: Color(0xFF000000),
  );

  // ── Accent ─────────────────────────────────────────────────────────────────

  /// Calendar's tint: systemRed. The today circle, today's weekday letter, the
  /// current-time line, every prominent action.
  static const accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF3B30),
    darkColor: Color(0xFFFF453A),
  );

  // ── Text ───────────────────────────────────────────────────────────────────

  static Color labelOf(BuildContext context) =>
      CupertinoColors.label.resolveFrom(context);

  static Color secondaryLabelOf(BuildContext context) =>
      CupertinoColors.secondaryLabel.resolveFrom(context);

  static Color tertiaryLabelOf(BuildContext context) =>
      CupertinoColors.tertiaryLabel.resolveFrom(context);

  /// Day numbers on Saturday and Sunday, and the weekday letters above the
  /// grid. Calendar greys the weekend rather than colouring it.
  static Color weekendLabelOf(BuildContext context) =>
      CupertinoColors.secondaryLabel.resolveFrom(context);

  /// White on the red today circle, in both modes.
  static const onAccent = Color(0xFFFFFFFF);

  // ── Hairlines ──────────────────────────────────────────────────────────────

  /// The rule between two weeks of the month grid and under the weekday row.
  static Color separatorOf(BuildContext context) =>
      CupertinoColors.separator.resolveFrom(context);
}
