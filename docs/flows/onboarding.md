# 2 · Onboarding & Paywall

Figma section `FLow Onboarding` (`2256:5906`). Built.

Three value-proposition pages with an ad between them, then the paywall. Code:
`Modules/Onboarding/`, `Modules/Store/Subscription/`.

## 01 / Onboarding — `2204:5141`

Photo, headline **"Build strength, improve flexibility, and feel your best"**, page dots, **Next**,
and a native ad card pinned below.

## 02 / Onboarding — `2146:3307`

Headline **"Explore 3,000+ Pilates workouts for every goal."**, **Next**. No ad card on this page —
the full-screen ad follows instead.

## 03 / Onboarding — Native Full-Screen Ad — `2256:6255`

A full-screen native ad between pages 2 and 3, with the **Ad** badge top-left and **INSTALL** at the
bottom. `NativeAdViewStyle.fullScreen`. Skipped for subscribers.

## 04 / Onboarding — `2204:4928`

Headline **"Join 100K+ Pilates Lovers on Their Wellness Journey"** over three testimonial cards
(component `Frame 189`, `2256:6159`):

| Name | Quote |
|------|-------|
| Maria Jane | Perfect for beginners. The exercises are easy to understand and I already feel more flexible after a few weeks. |
| Jennie | So calming and easy to use. I love doing a quick Pilates session before starting my day. |
| Anna | Great app for working out at home. No equipment needed for most workouts, which makes it super convenient |

These are static marketing copy, not fetched.

→ Paywall.

## 05 / Paywall — Free Trial — `2256:6360`

Code: `Modules/Store/Subscription/SubscriptionView.swift`, entry point `.onboarding`.

- Countdown strip **"⏰ Offer ends in"** with Hours / Minutes / Seconds (`01 : 32 : 12`).
- Title **Go Unlimited**, sub-head **"Claim your bonus deal"**, body **"Unlock everything with an
  exclusive limited-time offer."**
- Benefit row: **Unlock all features**, **No ads experience**.
- Three plans, always drawn in this order regardless of the enum's own order:

  | Plan | Price | Badges |
  |------|-------|--------|
  | Weekly Plan | `$7.99/Week` | — |
  | Monthly Plan | `$19.99/Month` | Best value · Save 50% · Pay $0 today |
  | Yearly Plan | `$59.99/Year` | Save 50% · Pay $0 today |

- **3 days free trial** toggle, **Due today $ 0.00**, CTA **Try now**.
- Footnote **"3 days free, then $19.99/month. Auto-renews until canceled."**
- **Use basic version** dismisses. Legal block plus **Terms of Use**, **Restore**, **Privacy Policy**.

Prices are placeholders — real ones come from StoreKit via `SubscriptionManager.availableProducts`.

## 06 / Paywall — No free trial — `2256:6464`

Identical, with the trial toggle off: **Due today $ 7.99** and footnote **"Auto renewable. Cancel
anytime"**. Which variant shows is driven by `LocalStorageService.weeklyFreeTrialEnabled` (exposed
as `AppFlags.iapTrialEnabled`) and by StoreKit introductory-offer eligibility.

### Entry points

`SubscriptionView.SubscriptionEntryPoint` decides analytics naming only; the screen is identical.
Current cases: `onboarding`, `onboardingSecond`, `home`, `library`, `settings`, `foodInfo`,
`discover`.

→ Profile Setup.
