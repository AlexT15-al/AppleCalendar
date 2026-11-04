import '../../app/theme/cal_metrics.dart';

/// How much of each day Month view shows — the Compact / Stacked / Details
/// choice in the view menu, and the stops a pinch moves between.
enum MonthDensity {
  /// One indicator per day that has anything on it.
  compact('Compact', CalMetrics.weekRowCompact),

  /// A coloured bar per event.
  stacked('Stacked', CalMetrics.weekRowStacked),

  /// Event titles.
  details('Details', CalMetrics.weekRowDetails);

  const MonthDensity(this.label, this.rowHeight);

  final String label;

  /// Height of one week row at this density.
  final double rowHeight;

  /// The density a week row of [height] draws.
  ///
  /// Taken from the height rather than stored alongside it, so that a row in
  /// the middle of an animated (or, later, pinched) resize always draws the
  /// content that fits it, switching over half-way between two stops.
  static MonthDensity forRowHeight(double height) {
    if (height < (compact.rowHeight + stacked.rowHeight) / 2) return compact;
    if (height < (stacked.rowHeight + details.rowHeight) / 2) return stacked;
    return details;
  }
}
