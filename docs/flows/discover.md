# 7 · Discover

Figma section `FLow Discover` (`2256:10183`). Built. Code: `Modules/Discover/`.

### UI note (`2495:5986`) — the rule this flow turns on

> Tất cả các bài tập trong Discover đều ở trạng thái **Locked** mặc định. User không thể xem nội
> dung bài tập khi chưa mở khóa. Khi user tap vào một bài tập, hiển thị **Reward Ads Popup**.

Every Discover workout opens locked; the exercise list is withheld until the user watches a rewarded
ad or subscribes. `WorkoutUnlockStore` owns that state — subscribers unlock everything, everyone
else gets what they have paid an ad for, kept in `LocalStorageService.unlockedWorkoutIds`.

## 01 / Discover — Overview — `2092:2189`

Title **Discover**, crown top-right.

- **Recent** — white card: thumbnail, plan name **Elite Pilates**, **Day 2**, and a coral progress
  bar reading **9%**, chevron right. Hidden outright until a plan is under way — the design has no
  empty state for it, and an empty card would sit above the fold on a first run.
- Native ad card.
- One carousel per API section, each headed by its name in Didot plus a coral underlined
  **View all**. Cards are photo, name, and `Level - N min`:

  | Section | Cards |
  |---------|-------|
  | Weight Loss Journey | Full body pilates & fat burn `Intermediate - 17 min` · HIIT cardio blast and core strength `Advanced - 25 min` |
  | Boost Flex & Balance | Sun Salutation Flow for Flexibility `Beginner - 20 min` · Power Vinyasa for Strength `Advanced - 25 min` |
  | Pilates Passion | Pilates Roll-Up for Core Strength `Intermediate - 15 min` · Breath Control and Alignment Practice `Beginner - 10 min` |

- Native ad card.
- **Weekly Top** + **View all** — ranked rows: position, thumbnail, name, `Level - N min`. Preview
  of five.

Data: `GET /workouts/discover?sectionLimit=6&weeklyLimit=5`. Section names come from the server, so
the carousels are whatever it returns — the three above are the design's examples, not a fixed set.
Recent is `GET /workout-programs/{currentProgramId}`, loaded separately so a failure costs the card
rather than the whole screen.

**View all is shown on every section**, not only ones with more rows than the carousel holds: most
sections the API ships today have four items or fewer, so gating it would mean the link almost never
appeared.

## 02 / Discover Category — Weight Loss Journey — `2101:3120`

Back chevron + section name in Didot, then full-width cards: photo, name, `Level - N min`. The
design places a native ad after the third card.

Data: `GET /workouts/discover/sections/{sectionId}?page=&limit=` — paged, loading the next page
three rows before the end.

**Implemented with one ad pinned to the bottom** rather than threaded through the list.

## 06 / Discover Ranking — Weekly Top — `2101:3303`

Back chevron + **Weekly Top**, then ranked rows 1…N: position, thumbnail, name, `Level - N min`. The
design places a native ad after the eighth row.

Data: `GET /workouts/weekly-top?page=&limit=` — paged the same way. `rank` is the server's position
in the ranking window; the row index only stands in if a response omits it.

**Implemented with one ad pinned to the bottom**, same as the category screen.

## 03 / Workout Discovery — Locked Details — `2092:2587`

Hero photo with back and gear. Then:

- Name **Full body pilates & fat burn** in Didot.
- Stats: **Advanced / Level** · **154.8 / Kcal** · **11 min / Net Duration**. Kcal shows here —
  Discover items carry `calories`, unlike program days.
- Description clamped to three lines with a coral **see more**.
- **Exercises (11)** — locked rows: a grey tile with a padlock and the label **Exercise 1**,
  **Exercise 2**, **Exercise 3**… No name, no photo.
- Footer **Unlock Now** with a padlock.

`GET /workouts/{workoutId}` is still called while locked — the screen needs the count, the duration
and the cover from it. Only the names and thumbnails are withheld.

Tapping a locked row or the footer both open the dialog.

## 04 / Workout Discovery — Unlock Options — `2099:2882`

Dimmed backdrop, white card with an **×** top-right:

- Title **Unlock This Workout** in Didot.
- Body **"Watch a short ad to download this workout, or enjoy unlimited downloads and a completely
  ad free experience."**
- **Get Premium** — filled coral, gem icon → paywall, entry point `.discover`.
- **Watch Ads** — outlined coral, video icon → rewarded ad, placement
  `LocalStorageService.discoverUnlockRewardedAd`.

On reward the workout is unlocked and the screen redraws in place.

**The reward callback also fires when no ad could be served** — ads switched off, no fill, load
failure. The workout unlocks anyway. That matches how the rest of the app treats a reward it cannot
deliver and keeps a failing ad network from walling off content, but it is a deliberate choice worth
revisiting if unlocks need to be strict.

## 05 / Workout Discovery — Unlocked Details — `2099:2984`

Same screen with the real list: thumbnail, name, duration — Scissor `01:00`, Oblique Crunch Reach
`02:30`, Tape `00:45`, Stapler `01:00`, Stapler `01:15`. Footer becomes **Start Now**, or
**Continue** once some exercises are done.

Rows push the shared [Exercise Detail](plan-and-workout.md#05--exercise-detail--view-instructions)
screen; the footer starts the shared [session player](workout-session.md).

Thumbnails fall back to the workout cover and so repeat — the API rarely has a per-exercise photo.
