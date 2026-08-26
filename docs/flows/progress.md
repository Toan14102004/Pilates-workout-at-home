# 8 · Progress

Figma section `FLow Progress` (`2256:10833`). **Built and verified against the live API** on
2026-08-26 -- registration, the calorie bar, the day picker, both weekly charts, the streak
calendar, and the full add/edit/delete activity flow all round-tripped real, non-fake data during
this pass. Code: `Data/Services/Progress/`, `Data/Services/Device/DeviceRegistrationService.swift`,
`Modules/Progress/`.

The Progress tab reports what the user has done: a calorie bar against a daily goal, a day picker,
the exercises and manual activities logged that day, and weekly charts.

## UI-fidelity pass, 2026-08-26

The first build of `ProgressHomeView` shipped functionally but drifted from `02 / Progress —
Activity Summary` (`2144:2384`) in several ways the user caught by comparing screenshots directly
against Figma. Fixed:

- **Daily Calories was a ring; the design is a flame icon + big bold number, a `kcal / goal` +
  `% completed` row, then a thin horizontal bar** (`mainColor` fill on `borderPrimary` track, not
  the ring's stroke). "Edit Goal" is plain secondary-grey text with a pencil, hidden until
  something is logged that day (matches `01 / Progress — Empty State` showing no Edit Goal link).
- **The day picker had no week navigation** -- added `‹`/`›` chevrons around the centred
  "Today"/date label (`ProgressHomeViewModel.shiftWeek(by:)`), forward disabled once the next
  week would run past today. Day circles now carry three states instead of one: default (white,
  bordered), has logged data (filled `secondaryColor`), selected (white with a `secondaryColor`
  outline) -- selection wins over the has-data fill when both apply.
- **The streak badge was a filled coral-tint capsule; the design is a white pill with a coral
  outline**, flame and count both `mainColor`.
- **Exercises and Activities were single-line text rows.** Exercises now match the "History"
  component: a completed workout shows a 3-column time/duration/calories stat block separated by
  hairline dividers; an unfinished one shows a thin `secondaryColor` progress bar and percentage
  instead (`2277:5740`'s UI note -- both states still push to Workout Day on tap, unchanged).
  Activities now match `card_actitives`: a `secondaryTint`-tinted icon square, then a 2-column
  duration/calories stat block. Both lists dropped their individual white row background, since
  they now sit inside one shared white `dailyActivitiesCard` (r24) with the day picker and the
  "Add More Activities" button -- a second nested white box would have been invisible against it.
- **Weekly chart bars were flat rounded rectangles in one colour.** Duration's bars are
  `#B3AABF` except the selected day's, which is `secondaryColor`; Calories' bars are
  `secondaryColor` uniformly. Bars are now pill-capped (`Capsule`) and both charts gained the
  same `‹`/`›` week navigation as the day picker (same `shiftWeek` call, one shared notion of
  "which week" across all three controls) plus an inline weekly total -- Figma showed a floating
  tooltip on Duration's peak bar and an inline total on Calories' header row specifically; using
  one inline total on both is a disclosed simplification rather than reproducing a floating,
  precisely-positioned callout bubble.

Verified by rebuilding, forcing the tab to open on Progress and stripping ad/section blocks one at
a time to bring off-screen content into a single screenshot (no scroll/tap tooling is available in
this environment), then reverting every temporary edit and confirming the diff against the last
commit was clean.

## Backend findings from this pass

Worth knowing before touching this code again -- each cost real debugging time to find.

- **`/activities/summary` and its alias `/users/{deviceId}/activity-summary` always report zero
  totals**, verified live against a device that `/activities` itself shows real entries for
  (retried after a delay in case of an indexing lag -- same result). Not used here; see
  `ProgressAPIModels.swift`'s header comment. `ProgressService.dailyTotals` reconstructs day
  totals from `/activities?from=&to=` instead -- one request per range, not one per day, since
  that endpoint accepts `from`/`to` directly. `streakDays` is likewise computed client-side
  (`ProgressService.streakDays`) over whatever window was already fetched, rather than trusted
  from the broken endpoint.
- **`/activities`'s `to` parameter is an exclusive upper bound** at 00:00 UTC of that date, not
  inclusive as the parameter name suggests -- `from=X&to=X` reliably returns nothing even for a
  day with real entries, while `date=X` (used for a single day) finds them. `ProgressService`
  pushes `to` one day later before sending it. Watch for this on any endpoint that takes a
  `from`/`to` pair, not just this one.
- **`POST /users` replies with the raw user document**, not the `{success, data}` envelope every
  other endpoint uses.
- **Completing a workout via `PUT /workouts/{workoutId}/progress` automatically files a matching
  activity** (`completion.activityId` in the response), which is what makes the calorie bar,
  weekly charts and `/users/{deviceId}/workouts/participated` have anything to show for a
  finished workout -- no separate write needed. `WorkoutProgressStore.markWorkoutCompleted` now
  pushes there best-effort after writing local progress; a failed push is not surfaced, since the
  local record already stands.
- **`caloriesMode: "estimated"` 400s** with `"onboarding.weightKg is required"` unless the device
  has a completed server-side onboarding with a weight on file -- which no anonymous device has,
  since the app has never pushed onboarding answers (see [[pilates-device-registration]]).
  `ProgressActivityFormViewModel` uses `caloriesMode: "custom"` instead, computing the estimate
  itself with the standard MET formula (`ProgressCategory.estimatedCalories`) against
  `ProfileSetupAnswers.currentWeightKg`, falling back to a nominal 65kg for anyone who has not
  answered that step.
- **`DELETE /activities/{id}` needs `deviceId` on the query string**, not in a JSON body --
  `NetworkService.delete(parameters:)` encodes `parameters` as a body for any non-GET method,
  so `ProgressService.deleteActivity` builds the query string itself instead of using it.
- **`/activities`'s `limit` param caps at 100** -- the streak calendar's ~35-42 day window is
  within that, but a device that logs more than 100 entries across the window would silently lose
  the overflow. Not paginated; flagged rather than fixed, since it is an edge case for casual use.

## 01 / Progress — Empty State — `2168:4804`

- Title **Progress**, streak badge showing **2**.
- **Daily Calories** — bar at **0 kcal**, **0 kcal / 200 kcal**, **0% completed**. No **Edit Goal**
  link in this state.
- Native ad card.
- **Daily Activities** — date **13 August**, week strip `Mo Tue We Th Fr Sa Su` over `10…16`.
- **Exercises** — empty: **No excercises yet** _(sic)_.
- **Activities** — empty: **No Activites yet** _(sic)_.
- **Add More Activities**.
- **Duration** chart — `9 Aug - 16 Aug`, axis **Duration (min)**, bars flat.
- **Calories** chart — `9 Aug - 16 Aug`, axis **Calories (Kcal)**, `83.1 kcal`.

Both misspellings are in the design; fix them in the app.

## 02 / Progress — Activity Summary — `2144:2384`

The populated state.

- **Daily Calories** with **Edit Goal**: **56 kcal**, **56 kcal / 200 kcal**, **26% completed**.
- **Daily Activities** — **Today**, same week strip.
- **Exercises** — one card per workout done that day:

  | Workout | Sub | Stats |
  |---------|-----|-------|
  | Zen Flow | Day 2: Intermediate | `Aug 11` · `08:30 AM` · Duration `15:45` · Kcal `90` |
  | Balance & Breath | Day 5: Beginner | `9%` |
  | Power Yoga | Day 6: Intermediate | `9%` |

- **Activities** — manual entries: **Walking** `20 min` / `90 Kcal`, **Yoga** `40 min` / `90 Kcal`.
- **Add More Activities**.
- Duration chart peaking at **75 min**, Calories chart at **83.1 kcal**.

### UI note (`2277:5740`) — exercise card states

> Card có 2 trạng thái UI:
> 1. **Completed** — Đã hoàn thành bài tập. Hiển thị trạng thái Completed. On tap: Navigate đến
>    Workout Day Screen.
> 2. **Incomplete** — Chưa hoàn thành bài tập. Hiển thị trạng thái chưa hoàn thành. On tap: Navigate
>    đến Workout Day Screen.

A finished card shows its duration and calories; an unfinished one shows a percentage. Both tap
through to the same place.

## 03 / Progress — Edit Calorie Goal — `2168:5224`

Dialog **Calories Goal** with a numeric field (`200`), **Cancel** and **Save**.

## 04 / Activity — Select Type — `2160:3392`

Header **Add Activity**, then a long scrolling list of activity types, each with an icon: Walking,
Running, Dance, Yoga, Cycling, Aerobic, Swimming, Skipping, Elliptical, Archery, Badminton,
Baseball, Basketball, Calories, Bowling, Boxing, Climbing, Cricket, Fencing, Fishing… A native ad
card sits near the bottom.

`Calories` appears in the middle of the list where an activity name should be — likely a stray
label. Check with design.

Data: `GET /activity-categories` (supports `popular` and `search`, neither of which the design uses).

## 05 / Activity — Add Empty Form — `2168:4357`

Header **Walking**, **Duration** `0 min`, **Estimated Calories** `0 Kcal`, CTA **Add** (inactive).

## 06 / Activity — Add Filled Form — `2168:4678`

**Duration** `20 min`, **Estimated Calories** `60 Kcal`, **Add** active. Calories look derived from
duration × the category's rate, so the field is computed, not typed.

## 07 / Activity — Edit Existing — `2168:4738`

Same form for an existing entry, with **Delete Activity** and **Save** in place of **Add**.

## 08 / Progress — Streak Calendar — `2168:5690`

Header **Your Streak**, illustration, **2-Day Streak !**, body **"Every check-in moves your forward.
Keep coming back and let your streak grow."**, then a month calendar for **August 2026** with
check-in days marked.

## API

Every endpoint answers without credentials — the spec declares `security` on `/activities/*` but
the server does not enforce it. What they need is a `deviceId` registered through `POST /users`;
`DeviceRegistrationService` (shared with `WorkoutProgressStore`, see below) handles that.

| Screen | Endpoint | Note |
|--------|----------|------|
| Calorie bar, charts, streak | `GET /activities?deviceId=&from=&to=` | reconstructed client-side -- `/activities/summary` is broken, see above |
| Daily lists | `GET /activities?deviceId=&date=` | |
| Add activity | `POST /activities` | `caloriesMode: "custom"`, calculated client-side |
| Edit / delete | `PATCH /activities/{activityId}` · `DELETE /activities/{activityId}?deviceId=` | delete needs `deviceId` on the query string, not the body |
| Activity types | `GET /activity-categories` | plain array under `data`, not `{items:[...]}` |
| Exercise cards | `GET /users/{deviceId}/workouts/participated` | populated once `WorkoutProgressStore` starts pushing completions |

The daily calorie **goal** has no endpoint — `LocalStorageService.dailyCalorieGoal` stores it.

## Workout-completion sync

Until this pass, `WorkoutProgressStore` (see [flow 5](workout-session.md)) tracked completion
locally only, which meant `/users/{deviceId}/workouts/participated` had nothing to return
regardless of what the user did in the app — Progress's "Exercises" card would have stayed empty
forever. `markWorkoutCompleted` now also calls `WorkoutService.saveProgress`
(`PUT /workouts/{workoutId}/progress`) with the completed exercise orders, best-effort and
non-blocking: the local write already stands either way, and completing a workout there auto-files
a matching activity server-side, which is what feeds the calorie bar and weekly charts too.
