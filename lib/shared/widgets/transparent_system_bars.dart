import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Fully transparent status and navigation bars, with icons that follow the
/// theme.
///
/// The package's own `GlassStatusBarStyle.light` / `.dark` hardcode an opaque
/// black Android navigation bar, and Android 15+ adds a contrast scrim unless a
/// style opts out of it explicitly — together they paint dark bands across the
/// top and bottom of the page. Pages set `statusBarStyle: none` and wrap
/// themselves in this instead.
class TransparentSystemBars extends StatelessWidget {
  const TransparentSystemBars({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    final icons = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: const Color(0x00000000),
        systemNavigationBarColor: const Color(0x00000000),
        systemNavigationBarDividerColor: const Color(0x00000000),
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        statusBarIconBrightness: icons,
        systemNavigationBarIconBrightness: icons,
        // iOS reads the inverse convention on this one.
        statusBarBrightness: brightness,
      ),
      child: child,
    );
  }
}
