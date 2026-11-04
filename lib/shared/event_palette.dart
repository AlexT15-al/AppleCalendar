import 'package:flutter/cupertino.dart';

/// The two colours an event chip is drawn in, derived from its calendar's.
///
/// Calendar never paints text in the raw calendar colour — a yellow or light
/// green label on a pale fill is unreadable. It tints the fill with the colour
/// and darkens it for the ink in light mode (lightens it in dark), which is
/// what [EventPalette.of] reproduces.
@immutable
class EventPalette {
  const EventPalette({required this.fill, required this.ink});

  final Color fill;
  final Color ink;

  static final _cache = <(int, Brightness), EventPalette>{};

  /// Cached per colour and brightness: a month grid draws the same handful of
  /// calendars hundreds of times, and the HSL round trip is not free.
  static EventPalette of(Color color, Brightness brightness) {
    return _cache.putIfAbsent((color.toARGB32(), brightness), () {
      final hsl = HSLColor.fromColor(color);
      if (brightness == Brightness.dark) {
        return EventPalette(
          fill: color.withValues(alpha: 0.30),
          ink: hsl
              .withLightness(
                (hsl.lightness + (1 - hsl.lightness) * 0.45).clamp(0.0, 1.0),
              )
              .toColor(),
        );
      }
      return EventPalette(
        fill: color.withValues(alpha: 0.20),
        ink: hsl
            .withLightness((hsl.lightness * 0.62).clamp(0.0, 1.0))
            .withSaturation((hsl.saturation * 0.95).clamp(0.0, 1.0))
            .toColor(),
      );
    });
  }
}
