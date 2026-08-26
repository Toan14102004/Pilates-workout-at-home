# 8 · Progress

Figma section `FLow Progress` (`2256:10833`). **Not built** — the tab still renders
`placeholderContent`.

The Progress tab reports what the user has done: a calorie ring against a daily goal, a day picker,
the exercises and manual activities logged that day, and weekly charts.

## 01 / Progress — Empty State — `2168:4804`

- Title **Progress**, streak badge showing **2**.
- **Daily Calories** — ring at **0 kcal**, **0 kcal / 200 kcal**, **0% completed**. No **Edit Goal**
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

Everything this flow needs already exists, and the endpoints answer without credentials — the spec
declares `security` on `/activities/*` but the server does not enforce it. What they do require is a
`deviceId` registered through `POST /users`, which the app does not do yet — so **Progress is
blocked on the registration step described in [Profile Setup](profile-setup.md)**, not on backend
work.

| Screen | Endpoint |
|--------|----------|
| Calorie ring, charts, streak | `GET /activities/summary?deviceId=&from=&to=` |
| Daily lists | `GET /activities?deviceId=&date=` |
| Add activity | `POST /activities` |
| Edit / delete | `PATCH /activities/{activityId}` · `DELETE /activities/{activityId}?deviceId=` |
| Activity types | `GET /activity-categories` |
| Exercise cards | `GET /users/{deviceId}/workouts/participated` |

`GET /users/{deviceId}/activity-summary?from=&to=` returns daily duration and calories and is the
likelier source for the two weekly charts.

The daily calorie **goal** has no endpoint — store it locally.
