//
//  ChallengeListCard.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// Full-width challenge card used by the "View all" list: a large photo, then the title with the
/// participant cluster below it and the Join CTA on the right.
///
/// Like `ChallengeCard`, `avatarUrls` and `participantsText` are optional because no Discover
/// endpoint returns a participant count or member avatars; the footer falls back to the workout's
/// own duration and exercise count, which is real data.
struct ChallengeListCard: View {
    let imageUrl: URL?
    let title: String
    let subtitle: String
    var avatarUrls: [URL] = []
    var participantsText: String?
    let buttonTitle: String
    let action: () -> Void

    private static let photoHeight: CGFloat = 170

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            RemoteImageView(url: imageUrl)
                .frame(height: Self.photoHeight)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))
                .padding(.horizontal, Layout.Spacing.s)
                .padding(.top, Layout.Spacing.s)

            HStack(alignment: .center, spacing: Layout.Spacing.s) {
                VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
                    Text(title)
                        .font(Typography.subtitleSmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(2)

                    HStack(spacing: Layout.Spacing.xs) {
                        if !avatarUrls.isEmpty {
                            AvatarStack(urls: avatarUrls)
                        }
                        Text(participantsText ?? subtitle)
                            .font(Typography.captionMedium)
                            .foregroundStyle(Asset.Color.textSecondary.color)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: Layout.Spacing.xs)

                Button(action: action) {
                    Text(buttonTitle)
                        .font(Typography.captionLarge)
                        .foregroundStyle(Asset.Color.white.color)
                        .padding(.horizontal, Layout.Spacing.m)
                        .padding(.vertical, Layout.Spacing.xs)
                        .background(Asset.Color.mainColor.color)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, Layout.Spacing.s)
            .padding(.bottom, Layout.Spacing.s)
        }
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))
    }
}
