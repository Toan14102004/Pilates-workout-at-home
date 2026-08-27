# Pilates Workout at Home — Flow Spec

What every screen shows, where its data comes from, and where it goes next. Written from the
Figma file, checked against the code and against live API responses.

**Design source:** [LA-051 Pilates work out at home (Copy)](https://www.figma.com/design/328okDV2pkzkx4JpIHPbWg/LA-051-Pilates-work-out-at-home--Copy-)
— file key `328okDV2pkzkx4JpIHPbWg`, canvas `UI`, last modified 2026-08-25.

Every screen below carries its Figma node id. Open one directly with
`…/LA-051-Pilates-work-out-at-home--Copy-?node-id=<id>` (replace `:` with `-`), or read it
offline through `Tools/figma.py node 328okDV2pkzkx4JpIHPbWg <id>` — the whole file is cached
under `.figma-cache/`, so that costs no API quota.

**Backend:** `https://pilates-workout.limgrow.com` — Swagger at `/api-docs`, schema at
`/api-docs-json`.

## Flows

| # | Flow | Figma section | Status |
|---|------|---------------|--------|
| 1 | [Splash & Language](flows/splash-and-language.md) | `Splash Screen`, `language` | Built |
| 2 | [Onboarding & Paywall](flows/onboarding.md) | `FLow Onboarding` | Built |
| 3 | [Profile Setup](flows/profile-setup.md) | `FLow Set up Profile` | Built |
| 4 | [Plan & Workout](flows/plan-and-workout.md) | `FLow Exercises` | Built |
| 5 | [Workout Session](flows/workout-session.md) | `FLow Practice` | Built |
| 6 | [Challenge](flows/challenge.md) | `FLow Challenge` | Partly built |
| 7 | [Discover](flows/discover.md) | `FLow Discover` | Built |
| 8 | [Progress](flows/progress.md) | `FLow Progress` | Built |
| 9 | [Profile](flows/profile.md) | `FLow Profile` | Not built |

"Status" is about the app, not the design: every flow here is fully designed.

## Tab bar

Four tabs, in `ContentView`: **Plan** (flow 4), **Discover** (flow 7), **Progress** (flow 8),
**Profile** (flow 9). Profile still renders `placeholderContent`. The header above the tabs shows
the tab's title and, for non-subscribers, a crown that opens the paywall.

## Colour styles

Read from the `Color Styles / Grouped Hex Palette` frame. Asset catalog names in brackets.

| Role | Hex | Asset |
|------|-----|-------|
| Primary / Main | `#FF8D76` | `mainColor` |
| Primary / Dark | `#DDBFB9` | — |
| Secondary / Main | `#9278B5` | `secondaryColor` |
| Secondary / Dark | `#B3AABF` | — |
| Secondary / Light | `#EEE8F5` | — |
| Background / canvas | `#FFF9F5` | `bgPrimary` |
| Background / ads | `#FFFFFF` | `bgAds` |
| Text / Primary | `#0E1329` | `textPrimary` |
| Text / Secondary | `#58575F` | `textSecondary` |
| Text / Disabled | `#CCCCCC` | `textTertiary` |
| Text / Error | `#EB4646` | — |
| Surface 01–04 | `#FFFFFF` `#F7F7F7` `#F2F2F2` `#EAEAEA` | `white`, `bgSecondary` |
| Icon primary / secondary / inverse | `#0E1329` `#CCCCCC` `#FFFFFF` | — |
| Border divider / default | `#EBEBEB` `#EAEAEA` | `borderPrimary` |

## Type

Body and UI text is **Inter**; display headings — screen titles, section headers, plan names — are
**Didot Bold**. Both scales live in `Typography.swift`, with the Didot sizes read off the Figma
frames:

| Style | Font | Used by |
|-------|------|---------|
| `displayLarge` | Didot 32 | the day number on Workout Day |
| `displayMedium` | Didot 24 | plan card and workout detail titles |
| `displaySmall` | Didot 22 | the tab header |
| `displayXSmall` | Didot 20 | Recent card, weekly-top rank numbers |
| `displaySection` | Didot 16 | every section header |

One thing is still off-design: the hero settings button draws an SF Symbol gear, because Figma's
**image export** sits on a tighter REST quota than the file read and has been returning 429. The
node to export when it clears is `I2027:627;2046:716`.

## Passes done against the live file

- **2026-08-26, cards & chrome** — `PlanHeroCard`, `ChallengeCard`, the Discover carousels/rows, the
  tab bar and header, Workout Day's stats row and footer. Found the plan card was a fabricated
  gradient (the design runs the cover photo edge to edge), icons at half the design's size, and
  Discover's "View all" links dead. See [flow 4](flows/plan-and-workout.md) and
  [flow 7](flows/discover.md).
- **2026-08-26, exercise flow** — Exercise Detail (`05`/`06`, node `2046:611` / `2050:1023`) and the
  Workout Settings sheet (`07`–`11`, node `2052:1688`…`2052:2587`). The sheet's background was the
  screen's cream (`bgPrimary`) instead of white, cards used the wrong grey, the rest-timer/countdown
  pills were filled buttons where the design tints a light card instead, and the Duration stepper
  used Didot for its value where the design uses Inter. All rewritten to match; see
  [flow 4](flows/plan-and-workout.md).

## Ads

Ad slots are drawn into almost every frame as a `BetterSleep: Sleep tracker` native card. In the
app they are `PreloadedNativeAdsView`, keyed per surface in `AdsPreloadService.AdsPreloadKey`.
Subscribers see none of them. Where a design shows an ad the spec notes it; where the app places
one differently from the design, that is called out.

## Known data gaps

Values the design asks for that no endpoint returns. Raise these with backend rather than
inventing numbers — the app hides the stat instead.

- **Participant counts and avatars** (`16K user` on Challenge cards) — no Discover response
  carries either.
- **Calories for a program day** — only Discover and weekly-top items have `calories`;
  `/workouts/{id}` for a program day does not.
- **Per-exercise photos** — usually absent (`media.hasImage: false`), so exercise rows fall back
  to the workout cover and repeat the same picture.
- **Duration and exercise count on `/workout-programs`** — absent, so the "11 Min · 12 Exercises"
  line needs a detail call per visible card.
