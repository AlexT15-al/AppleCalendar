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

  /// How opaque a row of [height] draws its content.
  ///
  /// 1 at rest on any stop, dipping to 0 at the switch-over points between two
  /// stops. That is the whole density cross-fade: as an animated resize carries
  /// a row past a switch-over, the old content fades out and the new fades in,
  /// without any cell owning an animation of its own.
  static double contentOpacity(double height) {
    const fadeZone = 10.0;
    final boundaries = [
      (compact.rowHeight + stacked.rowHeight) / 2,
      (stacked.rowHeight + details.rowHeight) / 2,
    ];
    var nearest = double.infinity;
    for (final b in boundaries) {
      final d = (height - b).abs();
      if (d < nearest) nearest = d;
    }
    return (nearest / fadeZone).clamp(0.0, 1.0);
  }
}
