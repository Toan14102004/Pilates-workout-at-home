//
//  PlanHeroCard.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The wide card in the "Your Plan" carousel: the cover photo runs the full card, with the plan
/// name, its metrics and a white pill CTA laid over the left side.
///
/// Metrics come from Figma `2306:6247` → `Header Image`: 299×192 at r16, copy inset 12pt from the
/// leading edge and 48pt from the top, 32pt between the text block and the button.
struct PlanHeroCard: View {
    let imageUrl: URL?
    let title: String
    let durationText: String?
    let exercisesText: String?
    let fallbackText: String
    let buttonTitle: String
    let action: () -> Void

    /// 299pt on the 375pt design — the content column less the 44pt the next card peeks by.
    static var cardWidth: CGFloat {
        UIScreen.main.bounds.width - Layout.Spacing.m * 2 - 44
    }

    static let cardHeight: CGFloat = 192

    /// The gap between cards in the carousel, per the design's 12pt auto-layout spacing.
    static let cardSpacing: CGFloat = 12

    var body: some View {
        ZStack(alignment: .topLeading) {
            RemoteImageView(url: imageUrl)
                .frame(width: Self.cardWidth, height: Self.cardHeight)

            // The design's placeholder art is a pale illustration, so its dark copy reads fine over
            // it. Real cover photos are arbitrary, so the copy column gets a light scrim; without
            // one the title is unreadable on roughly half the API's images.
            LinearGradient(
                colors: [Asset.Color.white.color.opacity(0.85),
                         Asset.Color.white.color.opacity(0.55),
                         .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: Self.cardWidth * 0.75)

            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                Text(title)
                    .font(Typography.displayMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                metrics

                // The design's gap is a flat 32pt under a single-line title. Anchoring the button
                // to the bottom instead keeps it in the same place when a real plan name wraps.
                Spacer(minLength: Layout.Spacing.s)

                startButton
            }
            .frame(width: Self.cardWidth * 0.55, height: Self.cardHeight, alignment: .topLeading)
            .padding(.leading, 12)
            .padding(.top, 48)
            .padding(.bottom, 32)
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var metrics: some View {
        if let durationText, let exercisesText {
            HStack(spacing: 9) {
                Text(durationText)
                Text(exercisesText)
            }
            .font(Typography.labelSmall)
            .foregroundStyle(Asset.Color.textPrimary.color)
        } else {
            Text(fallbackText)
                .font(Typography.labelSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)
        }
    }

    private var startButton: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(buttonTitle)
                    .font(Typography.captionLarge)
                    .foregroundStyle(Asset.Color.mainColor.color)

                Image(systemName: "play.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.s)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
