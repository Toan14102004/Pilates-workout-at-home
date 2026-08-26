# 4 · Plan & Workout

Figma section `FLow Exercises` (`2256:7960`) — despite the name, this is the **Plan** tab and
everything reachable from it. Built. Code: `Modules/Practice/`.

## Main screen — `2306:6247`

Title **Pilates Workout**, crown top-right for non-subscribers.

- **Your Plan** — horizontal carousel of gradient hero cards (`PlanHeroCard`): plan name in Didot,
  `11 Min · 12 Exercises`, and a white pill CTA **Start now** positioned inside the lower-left of the
  image. Sample plans: Gentle Pilates,
  Balanced Pilates, Elevated Pilates. Cards alternate through a purple/blue palette by position —
  the API returns no colour.
- Native ad card.
- **Challenge** + **View all** — carousel of `ChallengeCard`, see [flow 6](challenge.md).
- **Just for you** + **View all** — rows of thumbnail, name, `12 min - 12 exercises`.

### Data

| Section | Source |
|---------|--------|
| Your Plan | `GET /workout-programs?limit=10` |
| Challenge | `GET /workouts/discover` → `sections[0].items` |
| Just for you | `GET /workouts/discover` → `weeklyTop` |

"Just for you" should come from `GET /workouts/suggestions`, but that 404s until the device is
registered (see [Profile Setup](profile-setup.md)). Discover stands in.

`/workout-programs` returns no duration or exercise count, so the `11 Min · 12 Exercises` line falls
back to the plan's first workout day where the summary is missing.

### UI note (`2272:5651`) — plan card states

> Có 4 trạng thái của card theo thứ tự UI: **Completed** đã hoàn thành · **Next Exercise** card
> hiển thị bài tập tiếp theo cần thực hiện (chưa tập) · **Next Exercise** user đã tập bài tập tiếp
> theo nhưng chưa hoàn thành (đã tập) · **Other Phase Exercise** user chọn tập một bài thuộc phase
> khác không theo thứ tự Day trong lộ trình.

### Gaps

- Challenge cards show `12 min · N exercises` where the design shows `16K user` — no endpoint
  returns a participant count.
- **View all** on Challenge opens the Discover category for the section the carousel was filled
  from, and **View all** on Just for you opens Weekly Top — both carousels are fed by Discover, so
  those screens list the same thing in full. The design's own Challenge list
  ([flow 6](challenge.md)) is a different layout and is still unbuilt.

## 02 / 30-Day Workout Schedule — `2016:160`

Hero photo with a back button, then a native ad, then the schedule.

- **1/30 Days** with an overall progress bar.
- Phase sections: **Phase 1 — Ignite Your Body — 33%**, **Phase 2 — Powerful Flows**.
- Day rows on a connected timeline: **Day 1 · Finished!** (filled dot, check), **Day 2 ·
  12 min - 12 exercises** (current, outlined dot, card highlighted), **Day 3 · 9%** (started,
  showing a small progress bar).

Code: `Modules/Practice/Schedule/`. Data: `GET /workout-programs/{programId}`.

The API returns a flat day list; days are grouped on `phaseNumber`. A program without phases
collapses into one unnamed section rather than repeating the plan name as a header.

Per-day percentages come from `WorkoutProgressStore.progressFraction`, which reads
`workoutCompletedCounts` — the schedule only receives day summaries, never exercise lists, so the
count has to be recorded as the session runs.

## 03 / Workout Day — Ready to Start — `2027:624`

Hero photo with back and a gear (workout settings). Native ad. Then:

- **Day 2** in Didot, plan name **Elite Pilates** beneath.
- Stats row: **Advanced / Level** · **154.8 / Kcal** · **11 min / Net Duration**.
- **Exercises (11)** — rows of thumbnail, name, duration: Scissor `01:00`, Oblique Crunch Reach
  `02:30`, Tape `00:45`, Stapler `01:00`, Stapler `01:15`.
- Footer: **Start Now**.

Code: `Modules/Practice/Day/`. Data: `GET /workouts/{workoutId}`.

The Kcal column is **hidden** for a program day — that endpoint carries no calorie figure. It shows
for Discover workouts, which do.

Exercise thumbnails fall back to the workout cover, so they repeat: the API rarely has a per-exercise
photo (`media.hasImage: false`).

## 04 / Workout Day — In Progress — `2256:7609`

Same screen once at least one exercise is done: finished rows get a green check, and the footer
splits into **Restart** (outlined) and **Continue** (filled). Restart clears only this workout's
progress.

## 05 / Exercise Detail — View Instructions — `2046:611`

Matched to Figma: the Duration row is a single line (label left, minus/value/plus right — not the
vertical layout it had before), the pager's three pieces are grouped and centred rather than spread
edge to edge, and its Next button carries the design's light-coral circle. Instruction text renders
as plain lines (the API's array joined on `\n`), not bulleted — the design has no bullet glyph.

Video player at the top, then:

- Exercise name **Stapler**, **Duration `01:00`** with a stepper.
- **How to Do** — numbered steps.
- **Common Mistakes** — "Hunching the back", "Moving too fast".
- **Breathing Tips**.
- Pager **1/11** at the bottom; swiping moves between exercises.

Code: `Modules/Practice/ExerciseDetail/`. Data: `GET /exercises/{exerciseId}?workoutId=…` — the
`workoutId` scopes the duration to the workout it was opened from.

Where the server leaves `instructions.howTo` empty it often repeats the same prose in
`introduction`; the client splits that on newlines as a fallback.

## 06 / Exercise Detail — Edit Duration — `2050:1023`

The stepper active, showing `01:05`, with **Reset** and **Save** replacing the pager.

Edits are stored per exercise in `LocalStorageService.exerciseDurationOverrides` — **device-local**,
since no endpoint accepts a duration override. A saved edit wins over the server's figure everywhere:
the day list, the detail screen, and the net-duration total.

## 07–11 / Workout Settings

A sheet over the Workout Day screen. Code: `Modules/Practice/Settings/`, persisted to
`LocalStorageService.workoutSettings`.

| Frame | Node | Shows |
|-------|------|-------|
| 07 Overview | `2052:1688` | **Music** — Forbidden Nights, **See All Songs** · **Music Volume 80%** · **Duration** · **Rest timer — Off** · **Countdown before workout — 10s** |
| 08 Select Music | `2052:1967` | **Song List** picker: Forbidden Nights `02:29`, Midnight Whispers `03:15`, Echoes of Silence `04:02`, Neon Dreams `05:18`, Shadow Dance `02:47`, with **Save** |
| 09 Rest Timer On | `2052:2152` | **Rest timer** — _Set the reset time between exercise_ — wheel `10s / 15s`, **Done** |
| 10 Rest Timer Off | `2052:2399` | Same sheet with the toggle off and the wheel disabled |
| 11 Pre-Workout Countdown | `2052:2587` | **Countdown before workout** — wheel `5s / 10s / 15s`, **Done** |

The track list is hard-coded in `WorkoutSettings.swift` as `WorkoutTrack.samples`; there is no music
endpoint.

→ [Workout Session](workout-session.md).
