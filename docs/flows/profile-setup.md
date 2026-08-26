# 3 · Profile Setup

Figma section `FLow Set up Profile` (`2256:6633`). Built.

A 15-step quiz that personalises the plan. Every step shows `n/15` and a progress bar with a back
chevron; the primary button is **Next**. Code: `Modules/ProfileSetup/`, with the step list in
`ProfileSetupStep.swift` and answers accumulated into `ProfileSetupAnswers`.

Three step shapes recur:
- **Select** — a list of option cells (`ProfileSetupOptionCell`), single or multiple choice.
- **Number** — a large numeric field with a unit toggle (`ProfileSetupNumberInputCard`,
  `ProfileSetupUnitToggle`), keyboard up.
- **Generating** — the closing loader.

| # | Frame | Node | Question | Options |
|---|-------|------|----------|---------|
| 1 | Motivation | `2110:3928` | What motivates you the most? | Get in shape · Look Better · Reduce Stress & Relax · Sleep Better · Find Self-Love |
| 2 | Primary Goal | `2146:2771` | What's your main goal?<br>_Knowing your goals for a more targeted plan_ | Lose Weight · Tone Muscles · Improve Heathy · Improve Flexibility · Refine Posture |
| 3 | Height Empty | `2146:2823` | What's your height? | `0`, unit toggle **cm / fit & in** |
| 4 | Height Entered | `2185:12172` | — | filled state, `160` |
| 5 | Current Weight | `2146:3131` | What's your weight? | `48`, unit toggle **kg / Lbs** |
| 6 | Target Weight | `2185:12410` | What's your target weight? | `54`, unit toggle **kg / Lbs** |
| 7 | Age Validation Error | `2146:2867` | What's your age?<br>_It'll help us personalize your to better suit your age group._ | `23` **Years**, error **"Enter a valid age."** |
| 8 | Workout Location | `2146:2911` | Where do you typically work out? | On the Mat · On the Bed/Sofa · Any place is fine |
| 9 | Preferred Activities | `2146:2955` | What activities do you enjoy? | General Fitness · Wall Pilates · Calisthenics · Stretching · Yoga · Dancing · Recovery |
| 10 | Experience Level | `2146:2999` | What's your preferred workout level? | No experience · Less than 1 year · 1-3 years · 3+ years |
| 11 | Workout Intensity | `2146:3043` | What's your preferred workout level? | Easy to start · Break a light sweat · A bit challenging |
| 12 | Injured Areas | `2146:3087` | Any injured areas needing attention<br>_We will filter and reduce improper exercises for you_ | None of them · Knee · Lower back · Shoulder · Ankle · Wrist |
| 13 | Current Role | `2146:3219` | Which describes your current role? | student · full-time worker · part-time worker · freelancer · home and family life · running my own business · shifts or irregular hours · new chances or on a break · new phase of life · Other |
| 14 | Daily Activity Level | `2146:3263` | What does your typical day look like? | At work, mostly sitting · At home, mostly inactive · Walking every day · At work, mostly standing |
| 15 | Fitness Level | `2192:4598` | What's your fitness level? | Beginer · Intermediate · Advanced |

Steps 10 and 11 carry the same headline in the design — **"What's your preferred workout level?"** —
even though one asks about experience and the other about intensity. Treat step 11's as a copy bug
and check with design before shipping it twice.

Only steps 12 and 13 read as multi-select; the rest are single-select.

## Generating Plan — `2294:5732`

Title **"Your Personalized Pilates Plan"**, body **"We're putting together a routine based on your
goals, experience, and preferences."**, an animated loader, and **"This may take a few moments…"**
over a native ad card.

Code: `Modules/ProfileSetup/Steps/GeneratingPlanStepView.swift`.

## API

The answers exist locally but are **not pushed to the server yet**. The chain that would make
personalised endpoints work is:

1. `POST /users` — register the `deviceId`. Skipping this makes `/workouts/suggestions` answer
   **404 "User not found"**.
2. `PUT /users/{deviceId}/onboarding` — submit the answers. Until then suggestions answer
   **400 "User must complete onboarding before requesting personalized suggestions"**.

`GET /users/onboarding/options` returns the server's own field and option list — worth diffing
against the table above, since the two were authored separately.

No API key is involved: the spec declares `security` on `/users/*` but the server does not enforce
it. Wiring this up is client work.

→ Tab bar, Plan tab.
