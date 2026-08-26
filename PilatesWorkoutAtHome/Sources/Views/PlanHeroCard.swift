//
//  PlanHeroCard.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct PlanHeroCard: View {
    let imageUrl: URL?
    let title: String
    let durationText: String?
    let exercisesText: String?
    let fallbackText: String
    let buttonTitle: String
    let action: () -> Void

    static var cardWidth: CGFloat {
        UIScreen.main.bounds.width - Layout.Spacing.m * 2 - 44
    }

    static let cardHeight: CGFloat = 192
    static let cardSpacing: CGFloat = 12

    var body: some View {
        ZStack(alignment: .leading) {
            RemoteImageView(url: imageUrl)
                .aspectRatio(contentMode: .fill)
                .frame(width: Self.cardWidth, height: Self.cardHeight)
                .clipped()

            LinearGradient(
                colors: [
                    Asset.Color.white.color.opacity(0.85),
                    Asset.Color.white.color.opacity(0.4),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: Self.cardWidth * 0.7)

            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                    Text(title)
                        .font(Typography.displayMedium)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    metrics
                }

                Spacer(minLength: 0)
                startButton
            }
            .frame(width: Self.cardWidth * 0.55, alignment: .leading)
            .padding(Layout.Spacing.m)
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var metrics: some View {
        if let durationText, let exercisesText {
            HStack(spacing: Layout.Spacing.s) {
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
            HStack(spacing: Layout.Spacing.s) {
                Text(buttonTitle)
                    .font(Typography.captionLarge)
                    .foregroundStyle(Asset.Color.mainColor.color)

                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.vertical, Layout.Spacing.s)
            .background(Asset.Color.white.color)
            .clipShape(Capsule())
        }
    }
}
