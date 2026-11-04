# Apple Calendar clone (iOS 26/27) — project rules

A 1:1 Flutter clone of Apple Calendar on iPhone, iOS 26/27, built with
`liquid_glass_widgets` (latest, currently 1.16.1). Built page by page.

Read `.claude/skills/liquid-glass-widgets/SKILL.md` before writing or reviewing
any UI that uses the package. Verify every package API against the source in
the pub cache (`~/.pub-cache/hosted/pub.dev/liquid_glass_widgets-*/lib`) —
never guess a parameter.

## Non-negotiables

- **Glass quality is always premium**, with the package's **iOS 27 preset**:
  `GlassThemeData.ios27()` on `LiquidGlassWidgets.wrap`, and
  `CalGlass.settings(context)` (`LiquidGlassSettings.ios27Light/Dark`) +
  `CalGlass.quality` on any glass outside a `GlassScaffold`. No adaptive
  quality.
- **Every liquid glass control is at least 48×48** (`CalMetrics.minGlassControl`)
  — buttons, capsules, groups, bar items (`buttonSize: 48`). Larger where it
  reads better.
- **Containers are squircles**: `LiquidRoundedSuperellipse` on glass,
  `RoundedSuperellipseBorder` / `ClipRSuperellipse` elsewhere. Capsules (radius
  = half height) stay true capsules.
- **Glass only where iOS puts it**: bars, toolbars, floating buttons, menus,
  sheets, dialogs. Grids, lists and cards are opaque (`GlassSurfaceStyle.solid`
  for package cards). Never refractive glass inside glass.
- **Apple motion**: springs in the duration/bounce model (`CalMotion`);
  overshoot only when a gesture threw the motion; everything respects Reduce
  Motion (`CalMotion.of`).
- **No hardcoded values in widgets**: colours in `CalColors`, sizes in
  `CalMetrics`, motion in `CalMotion`, glass in `CalGlass`.
- **Performance**: identity-stable glass settings, `GlassBackdropGroup` around
  side-by-side glass, `RepaintBoundary` around animated chrome, no new packages
  without a reason.

## Layout of the code

- `lib/app/` — app root, `CalendarScope`, `TodayClock`, theme tokens, and the
  shell (`CalendarChrome`: the floating bottom toolbar drawn above the
  Navigator).
- `lib/domain/` — `CalendarEvent`, `CalendarSource`.
- `lib/data/` — `EventStore` (per-day index), sample data.
- `lib/features/<page>/` — one folder per screen.
- `reference/` — the screenshots each page is matched against.

## Checks before every push

```bash
flutter analyze
flutter test
```

A visual check is possible in the cloud container by building a web copy in
the scratchpad (local CanvasKit with `--no-web-resources-cdn`, Inter mapped to
the SF family names) and screenshotting it with Playwright. Web renders the
lightweight glass shader, not premium — use it for layout, not for the glass.
