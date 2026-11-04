# Calendar

A 1:1 clone of Apple Calendar on iPhone (iOS 26/27) in Flutter, using
[`liquid_glass_widgets`](https://pub.dev/packages/liquid_glass_widgets) with the
iOS 27 Liquid Glass material at premium quality.

## Status

| Page | State |
| --- | --- |
| Month view (Compact / Stacked / Details, Today) | ✅ first pass |
| Year view | next |
| Day view | planned |
| List mode, search | planned |
| Event details, new / edit event | planned |
| Calendars, Inbox | planned |

## Run

```bash
flutter pub get
flutter run
```

Requires Flutter ≥ 3.41 (Impeller). Premium glass renders on iOS, macOS and
Android Vulkan; other backends fall back to the package's lighter shader.
