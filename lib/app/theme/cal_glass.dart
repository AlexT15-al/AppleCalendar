import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// The app's one glass material: the package's iOS 27 preset, at premium.
///
/// Two project rules live here:
///
/// - **Always premium.** The theme installed on `LiquidGlassWidgets.wrap` is
///   `GlassThemeData.ios27()`, whose variants are already premium. [quality]
///   is still passed explicitly on glass that sits outside a `GlassScaffold`
///   (the floating toolbar above the Navigator, menus), because a bar's
///   `GlassIsolationScope` carries its own default tier and would otherwise
///   win.
/// - **One material.** Every surface uses `LiquidGlassSettings.ios27Light` /
///   `ios27Dark`. Those are `static const` instances, so a glass widget handed
///   one always sees the *same object* — and glass compares settings by
///   identity to decide whether to redo its blur and shader work.
abstract final class CalGlass {
  static const GlassQuality quality = GlassQuality.premium;

  static const GlassThemeData theme = GlassThemeData.ios27();

  /// `CupertinoTheme.brightness` is null when the app follows the OS, which it
  /// does — fall back to the platform rather than assuming light.
  static Brightness brightnessOf(BuildContext context) =>
      CupertinoTheme.maybeBrightnessOf(context) ??
      MediaQuery.platformBrightnessOf(context);

  static LiquidGlassSettings settings(BuildContext context) =>
      brightnessOf(context) == Brightness.dark
      ? LiquidGlassSettings.ios27Dark
      : LiquidGlassSettings.ios27Light;
}
