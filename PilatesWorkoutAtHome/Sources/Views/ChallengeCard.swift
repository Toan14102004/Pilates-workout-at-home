//
//  ChallengeCard.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The "Challenge" carousel card: inset photo, title, then a footer row with the participant
/// cluster on the left and the Join CTA pinned bottom-right.
///
/// `avatarUrls` and `participantsText` are optional because the API serves neither -- no Discover
/// endpoint returns a participant count or member avatars. When they are nil the footer falls back
/// to the workout's own duration/exercise line, which is real data, and the CTA keeps its place.
struct ChallengeCard: View {
    let imageUrl: URL?
    let title: String
    let subtitle: String
    var avatarUrls: [URL] = []
    var participantsText: String?
    let buttonTitle: String
    let action: () -> Void

    static var cardWidth: CGFloat {
        UIScreen.main.bounds.width * 0.56
    }

    private static let photoHeight: CGFloat = 128

    /// Fixed so cards sit level in the carousel and the CTA stays pinned bottom-right even when a
    /// title wraps to two lines.
    private static let cardHeight: CGFloat = 224

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            RemoteImageView(url: imageUrl)
                .frame(width: Self.cardWidth - Layout.Spacing.s * 2, height: Self.photoHeight)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))
                .padding(.horizontal, Layout.Spacing.s)
                .padding(.top, Layout.Spacing.s)

            Text(title)
                .font(Typography.subtitleSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .lineLimit(2)
                .padding(.horizontal, Layout.Spacing.s)

            Spacer(minLength: 0)

            footer
                .padding(.horizontal, Layout.Spacing.s)
                .padding(.bottom, Layout.Spacing.s)
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight, alignment: .topLeading)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))
    }

    private var footer: some View {
        HStack(spacing: Layout.Spacing.xs) {
            if !avatarUrls.isEmpty {
                AvatarStack(urls: avatarUrls)
            }

            Text(participantsText ?? subtitle)
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: Layout.Spacing.xs)

            Button(action: action) {
                Text(buttonTitle)
                    .font(Typography.captionLarge)
                    .foregroundStyle(Asset.Color.white.color)
                    .padding(.horizontal, Layout.Spacing.s)
                    .padding(.vertical, Layout.Spacing.xs)
                    .background(Asset.Color.mainColor.color)
                    .clipShape(Capsule())
            }
        }
    }
}

/// Overlapping circular avatars, as the design shows next to the participant count.
struct AvatarStack: View {
    let urls: [URL]
    var diameter: CGFloat = 20
    var maximum: Int = 3

    var body: some View {
        HStack(spacing: -diameter * 0.35) {
            ForEach(Array(urls.prefix(maximum).enumerated()), id: \.offset) { _, url in
                RemoteImageView(url: url)
                    .frame(width: diameter, height: diameter)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Asset.Color.white.color, lineWidth: 1.5))
            }
        }
    }
}
