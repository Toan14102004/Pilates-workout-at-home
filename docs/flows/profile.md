# 9 · Profile

Figma section `FLow Profile` (`2264:11906`). **Not built** — the tab still renders
`placeholderContent`. Some pieces exist elsewhere and can be reused rather than rewritten.

## 01 / Profile — Overview — `2169:5782`

- Title **Profile**, streak badge showing **2**.
- Avatar and name **Annie**.
- Premium card: **Premium Access**, **"Join Pro to enjoy all the benefits"**, CTA **Try Premium**.
  Hidden for subscribers.
- Native ad card.
- Menu rows:

  | Row | Destination |
  |-----|-------------|
  | My Profile | 02 / Personal Details |
  | Workout Settings | 04 / Workout Settings |
  | Reminder | 05 / Reminder List |
  | Rate Us | system review prompt |
  | Language | existing `LanguageView` |
  | Invite Friends | share sheet |
  | Terms of Use | web |
  | Privacy Policy | web |

`Modules/Settings/SettingView.swift` already covers much of this menu, along with
`Modules/Settings/Feedback/` and `Modules/Settings/Language/`. Building the Profile tab is mostly a
matter of restyling that screen to the design and adding the rows it lacks.

## 02 / Profile — Personal Details — `2180:7823`

Header **My Profile**, editable avatar, then:

- **Name** — `Annie`.
- Unit toggle **Kg, cm / Ibs, ft** _(sic — "lbs")_.
- **Height** `160 cm` · **Weight** `45 kg` · **Target Weight** `52 kg`.
- Native ad card.

These are the answers collected in [Profile Setup](profile-setup.md), so the screen edits
`ProfileSetupAnswers`. There is no endpoint to update a user's profile after onboarding beyond
`PUT /users/{deviceId}/onboarding`, which replaces the whole answer set.

## 03 / Profile — Select Photo System Picker — `2264:11862`

The system photo picker, drawn as a flat image in Figma. `Views/ImagePicker.swift` and
`Views/CameraImagePicker.swift` already exist, with `CropImageView` for cropping. The avatar is
device-local — no upload endpoint.

## 04 / Profile — Workout Settings — `2180:7339`

The same settings as the in-workout sheet, as a full screen: **Music** — Forbidden Nights, **See All
Songs** · **Music Volume 80%** · **Duration** · **Rest timer — Off** · **Countdown before workout —
10s**.

Reuse `Modules/Practice/Settings/`; both read and write the one `LocalStorageService.workoutSettings`
so the two entry points cannot drift.

## 05 / Profile — Reminder List — `2183:9314`

Header **Reminder**, then a card per reminder: time (**17:00**, **05:00**), a day-of-week strip
`Su Mo Tu We Th Fr Sa` with the active days highlighted, a repeat summary **Every day**, and a
toggle. **Add** at the bottom.

## 06 / Profile — Add Reminder Time — `2183:9416`

Sheet **Reminder** over the list: a time wheel (`09…13` / `30…34`), the day strip, repeat **Every
day**, then **Cancel** / **Done**.

Entirely local — scheduled with `UNUserNotificationCenter`, no endpoint. The project already has
push handling in `Application/`, and permission is requested through
`Application/Permission/`.
