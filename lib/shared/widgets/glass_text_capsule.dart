import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../app/theme/cal_colors.dart';
import '../../app/theme/cal_glass.dart';
import '../../app/theme/cal_metrics.dart';

/// A glass capsule with a text label — "Today" in the toolbar.
///
/// A true capsule: a rounded rectangle whose radius is half its height, which
/// is what iOS draws for text buttons. (Containers are squircles; capsules are
/// not, and a superellipse at half-height reads as a lozenge.)
///
/// At least [CalMetrics.minGlassControl] in both axes, whatever the label.
class GlassTextCapsule extends StatelessWidget {
  const GlassTextCapsule({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
  });

  final String label;
  final VoidCallback onTap;

  /// An optional glyph before the label — the chevron of a back capsule.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    const height = CalMetrics.minGlassControl;
    return GlassButton.custom(
      onTap: onTap,
      label: label,
      height: height,
      shape: const LiquidRoundedRectangle(borderRadius: height / 2),
      settings: CalGlass.settings(context),
      quality: CalGlass.quality,
      // Outside a scaffold there is no ancestor glass layer to borrow, and a
      // glass widget without one has nothing to render into.
      useOwnLayer: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: CalMetrics.minGlassControl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CalMetrics.textCapsulePadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 4)],
              Text(
                label,
                style: TextStyle(
                  color: CalColors.labelOf(context),
                  fontSize: CalMetrics.barTextSize,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.41,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
