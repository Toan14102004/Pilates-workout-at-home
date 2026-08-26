# 1 · Splash & Language

Figma sections `Splash Screen` (`2256:5100`) and `language` (`2256:5152`). Built. Rechecked 2026-08-26 against the cached Figma file; the language list order, row geometry, radio states, and native-ad height now match the frames.

## 01 / Splash Screen — `2256:5017`

Full-bleed photo, logo, tagline **"Move. Breathe. Feel stronger."**, and a progress bar with
**"This action can contain ads"** underneath.

Code: `Modules/App/Splash/SplashView.swift`. The splash holds while the app boots services and,
unless suppressed, loads the splash interstitial.

→ **02 / Interstitial Ad**, then Welcome.

## 02 / Interstitial Ad — `2256:5103`

Full-screen interstitial, no app chrome. `AdsManager.showSplashInterstitial` — bypasses the normal
frequency gate, and is skipped for subscribers. `suppressNextSplashInterstitial` suppresses it once.

## 01 / Welcome — Get Started — `2247:5261`

Photo hero, a **1.000.000+ / Download the App** social-proof badge, heading **"Find Your Perfect
Flow"**, body copy, and a **Get Started** button.

Code: `Modules/App/Splash/WelcomeView.swift`. Shown on first run only — `SplashView` checks
`LocalStorageService.isFirstTimeOpenApp` and, on a repeat launch, pushes
`RootView.Coordinator.Navigation.content` straight to the tab bar instead.

→ **Get Started** always pushes Language.

## 01 / Language — No Selection — `2256:5240`

Title **Language**, then a list: Korean, Japan, French, Russian, Spanish, Hindi, English. Each row
is a flag, a name, and a radio on the right. A native ad card sits at the bottom above **INSTALL**.
Nothing is selected, and the confirm control is inactive.

## 02 / Language — Korean Selected — `2256:5269`

Same list with Korean selected — filled radio, tinted row — and the confirm control now active.

Code: `Modules/Settings/Language/`. The same screen serves two entry points:
`LanguageView(viewModel: .init(isOnboardingContext: true))` during first run, and the plain
initialiser from Profile → Language. Only the onboarding one advances the flow; the settings one
pops back.

Selection is persisted by `LanguageManager` and applied through `environment(\.locale)` in
`RootView`, so the change takes effect without a relaunch.

→ Onboarding (first run only).
