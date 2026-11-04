import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Motion tokens, in Apple's duration-and-bounce model.
///
/// The rule, from Apple's "Designing Fluid Interfaces": overshoot is only
/// right when a gesture carried momentum into the motion. Something that just
/// appears — a title changing, a page scrolling to Today — settles without
/// bouncing. So [standard] is the default and [momentum] the exception.
///
/// `GlassSpring` is the package's own preset family, built on the same
/// `SpringDescription.withDurationAndBounce`, so our motion and the glass
/// controls' share one model.
abstract final class CalMotion {
  // ── Springs ────────────────────────────────────────────────────────────────

  /// Critically damped, 0.4s response: Apple's "move / reposition" spring.
  static SpringDescription get standard =>
      GlassSpring.smooth(duration: const Duration(milliseconds: 400));

  /// Slight overshoot for motion a gesture threw.
  static SpringDescription get momentum =>
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 400),
        bounce: 0.2,
      );

  // ── Curves (for implicit animations, which take a curve) ───────────────────

  /// Stand-in for [standard] where a widget wants a curve.
  static const standardCurve = Curves.easeOutCubic;
  static const standardDuration = Duration(milliseconds: 350);

  /// Scrolling the month grid to Today. Ease in and out rather than ease out:
  /// the content travels a long way and should not start at full speed.
  static const scrollToCurve = Curves.easeInOutCubic;
  static const scrollToDuration = Duration(milliseconds: 450);

  /// Beyond this many months the grid jumps most of the way and animates only
  /// the last stretch, as Calendar does — a smooth scroll across years would
  /// be a blur of rows and take seconds.
  static const int scrollToMaxAnimatedMonths = 3;

  /// The sticky month title swapping as the grid scrolls into another month.
  static const titleSwapDuration = Duration(milliseconds: 180);

  /// Switching month density (Compact / Stacked / Details).
  static const densitySwapDuration = Duration(milliseconds: 300);

  // ── Accessibility ──────────────────────────────────────────────────────────

  /// Collapses a duration to zero under Reduce Motion. Colour and opacity
  /// still carry meaning there; travel and springing do not.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
