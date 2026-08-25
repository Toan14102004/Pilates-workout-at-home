//
//  PlanHeroCard.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The wide gradient card in the "Your Plan" carousel: copy on the left, cover photo bleeding off
/// the right edge, and a white pill CTA. Distinct from `WorkoutPlanCard`, which is the smaller
/// photo-on-top card used by "Challenge".
///
/// Colours and metrics here are read off the Figma screenshot, not the file -- the Figma REST API
/// is rate limited until 26/08, so treat them as close approximations to re-verify.
struct PlanHeroCard: View {
    let imageUrl: URL?
    let title: String
    let durationText: String?
    let exercisesText: String?
    let fallbackText: String
    let buttonTitle: String
    /// Picks which gradient this card gets; the API carries no colour information.
    let paletteIndex: Int
    let action: () -> Void

    /// Leaves the next card peeking at the right edge, the way the design shows it.
    static var cardWidth: CGFloat {
        UIScreen.main.bounds.width - Layout.Spacing.m * 2 - 44
    }

    static let cardHeight: CGFloat = 152

    var body: some View {
        ZStack(alignment: .leading) {
            PlanCardPalette.gradient(for: paletteIndex)

            coverPhoto

            sparkles

            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                Text(title)
                    .font(.custom("Didot-Bold", size: 21))
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                metrics

                Spacer(minLength: Layout.Spacing.xs)

                startButton
            }
            .padding(Layout.Spacing.m)
            .frame(width: Self.cardWidth * 0.58, alignment: .leading)
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    /// The API serves a rectangular photo where the design uses a cut-out model, so the left edge
    /// is faded into the gradient instead of ending on a hard rectangle seam.
    private var coverPhoto: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            RemoteImageView(url: imageUrl)
                .frame(width: Self.cardWidth * 0.5, height: Self.cardHeight)
                .mask(
                    LinearGradient(
                        colors: [.clear, .black, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }

    private var sparkles: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: Layout.Spacing.s) {
                Image(systemName: "sparkle")
                    .font(.system(size: 13))
                    .foregroundStyle(Asset.Color.white.color.opacity(0.9))
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundStyle(Asset.Color.white.color.opacity(0.7))
                    .padding(.leading, Layout.Spacing.m)
                Spacer(minLength: 0)
            }
            .padding(.top, Layout.Spacing.l)
            .padding(.trailing, Self.cardWidth * 0.4)
        }
    }

    @ViewBuilder
    private var metrics: some View {
        if let durationText, let exercisesText {
            HStack(spacing: Layout.Spacing.s) {
                Text(durationText)
                Text(exercisesText)
            }
            .font(Typography.captionMedium)
            .foregroundStyle(Asset.Color.textPrimary.color)
        } else {
            Text(fallbackText)
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.textPrimary.color)
        }
    }

    private var startButton: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.xs) {
                Text(buttonTitle)
                    .font(Typography.labelMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                // TODO: swap for the real Figma play glyph once the Figma API quota returns.
                Image(systemName: "play.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.s)
            .background(Asset.Color.white.color)
            .clipShape(Capsule())
        }
    }
}

/// Gradients for the plan carousel. The API returns no colour, so cards cycle through the palette
/// by position -- matching the design, where consecutive cards alternate purple / blue.
enum PlanCardPalette {
    private static let pairs: [(String, String)] = [
        ("#D7C6F3", "#EFE7FD"),
        ("#C6DCF4", "#E6F0FC"),
        ("#F8D3C6", "#FDEBE2"),
        ("#CFEBDC", "#E9F7F0"),
    ]

    static func gradient(for index: Int) -> LinearGradient {
        let pair = pairs[abs(index) % pairs.count]
        return LinearGradient(
            colors: [Color(hex: pair.0), Color(hex: pair.1)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
