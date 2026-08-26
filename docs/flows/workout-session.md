# 5 · Workout Session

Figma section `FLow Practice` (`2256:8580`) — the guided player. Built. Code:
`Modules/Practice/Session/`.

Entered from **Start Now** / **Continue** on the Workout Day screen. The player walks the exercise
list in order, resuming at the first one not yet finished.

## 01 / Get Ready — `2091:1177`

Countdown **10** over the exercise clip, caption **Get ready!**, exercise name **Scrissor**, and
**Skip**. Length comes from `WorkoutSettings.preWorkoutCountdownSeconds` (default 10s, set in
[Workout Settings](plan-and-workout.md#0711--workout-settings)).

## 02 / Exercise Instructions — `2092:1391`

The same countdown with the instruction sheet raised over it: **How to Do**, **Common Mistakes**,
**Breathing Tips** — the same content as the Exercise Detail screen, so the user can read the form
before the timer starts. **Skip** dismisses.

## 03 / Exercise In Progress — `2092:1569`

Video playing, ring timer counting down **00:52**, exercise name, and **Exercise 1/11** with a
progress bar. Transport controls sit under the clip.

## 04 / Exercise Paused — `2092:1665`

Same layout, timer held at **00:03**, play/pause flipped.

## 05 / Rest Interval — `2092:1752`

Between exercises when the rest timer is on: **Rest**, countdown **00:09**, **Skip**, and a preview
of what is next — **Next: 5/11 · Oblique Crunch Reach**. Length is
`WorkoutSettings.restTimerSeconds`; when the timer is off this screen is skipped entirely.

## 06 / Pause Options — `2092:1859`

Sheet raised on pause:

- Title **"You're doing great"**, body **"Want to keep going, take a short break, or continue
  later?"**
- **Keep exercising** — resume.
- **Restart this exercise** — back to the start of the current exercise.
- **Do it later** — leave the session, keeping progress.

## 07 / Completed — `2092:2005`

Illustration, **All Done!**, body **"You've completed all your workouts today. Your body is getting
stronger keep it up!"**, and **Finish**.

### UI note (`2301:5855`)

> Màn này chỉ được hiển thị khi user đã hoàn thành tất cả các bài tập trong phase/day hiện tại.

So this is the end-of-day screen, not an end-of-exercise one.

## Main screen after starting — `2513:7368`

### UI note (`2513:7756`)

> Khi user đã chọn plan và bắt đầu tập, button "Start Now" trên Main Screen sẽ đổi thành "Continue"
> và hiển thị Day hiện tại mà user đang thực hiện.

The plan card then reads **DAY 4** in place of the plan name, with **Contiune** _(sic — the design's
typo; the app spells it "Continue")_ on the button. Implemented in
`PracticeHomeViewModel.cardTitle(for:)` and `buttonTitle(for:)`, keyed on
`LocalStorageService.currentProgramId` / `currentWorkoutDayId`.

## Progress recording

`WorkoutProgressStore` writes locally first so the UI reacts instantly and keeps working offline —
which matters mid-workout. It records:

- `completedExerciseIds` — **keyed by workoutId**. The API reuses one `exerciseId` across many
  workouts, so a flat list would mark an exercise done everywhere it appeared.
- `completedWorkoutIds` — finished workouts.
- `workoutCompletedCounts` — how far into each workout, for the schedule's per-day bar.

The shape deliberately mirrors what `PUT /workouts/{workoutId}/progress` expects — exercise `order`s
and an elapsed count excluding paused and backgrounded time — so pushing to the server later is a
transport change, not a rewrite. **Nothing is synced today**;
`DELETE /workouts/{workoutId}/progress` is likewise unused.
