# 6 · Challenge

Figma section `FLow Challenge` (`2513:7780`). Partly built.

Challenge is the multi-day programme the Plan tab promotes. The carousel exists; the two screens
behind **View all** do not.

## Main screen — `2324:5817`

The Plan tab, with the **Challenge** carousel in view: inset photo, name, and a footer pairing an
avatar cluster + participant count with the CTA.

| Card | Participants | CTA |
|------|--------------|-----|
| Full body pilates | 16K user | Join now |
| Pilates Glow Up | 7.5K user | Join now |

Code: `Views/ChallengeCard.swift`, fed from `GET /workouts/discover` → `sections[0].items`.

**No endpoint returns a participant count or member avatars.** `ChallengeCard` takes `avatarUrls`
and `participantsText` as optionals and, when they are nil, falls back to the workout's own
`12 min · N exercises` line — real data, and the CTA keeps its place.

## 01 / Challenge — view all — `2495:6028`

**Not built.** Header **Challenge** with a back button, then full-width cards stacked vertically:

| Card | Participants | CTA |
|------|--------------|-----|
| Full body pilates | 16K user | Join now |
| Morning yoga flow | 12K user | Join Now |
| Evening meditation | 9K user | Get started |

A native ad card sits between the second and third.

The CTA label varies per card in the design (**Join now** / **Join Now** / **Get started**). Nothing
in the data explains the difference — treat it as design noise unless design confirms otherwise.

The **View all** control on the Plan tab is currently `Button("View all") {}` — a dead button. The
nearest existing screen is `DiscoverCategoryView`, which renders exactly this layout for a Discover
section; pointing Challenge's link at it would need the section id the carousel was filled from.

## 02 / Plan — 30-Day Workout Schedule — `2495:6401`

**Not built.** A calendar-grid schedule, distinct from the timeline on the
[Plan flow's schedule](plan-and-workout.md#02--30-day-workout-schedule):

- Hero photo, native ad.
- Title **Full body pilates**, subtitle **28- Day**.
- **Week 1** … **Week 4**, each a row of day chips numbered 1–7.
- Footer **Continue**.

Data would come from `GET /workout-programs/{programId}`, the same call the timeline schedule uses —
the grid is a second presentation of the same day list, chunked by seven rather than by
`phaseNumber`.
