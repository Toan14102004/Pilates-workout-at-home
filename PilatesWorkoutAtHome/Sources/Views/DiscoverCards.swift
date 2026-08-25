//
//  DiscoverCards.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// Section title plus the coral "View all" link, above every Discover carousel.
struct SectionHeaderRow: View {
    let title: String
    /// Optional so a header can stand without a link; every Discover section passes one.
    var viewAll: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Didot-Bold", size: 18))
                .foregroundStyle(Asset.Color.textPrimary.color)
                .lineLimit(1)

            Spacer(minLength: Layout.Spacing.s)

            if let viewAll {
                Button("View all", action: viewAll)
                    .font(Typography.labelMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .underline()
            }
        }
    }
}

/// A card in a Discover carousel: photo on top, then the workout name and its "Level · N min"
/// caption on the page background.
struct DiscoverWorkoutCard: View {
    let workout: WorkoutDay
    let action: () -> Void

    static var cardWidth: CGFloat { UIScreen.main.bounds.width * 0.62 }

    private static let photoHeight: CGFloat = 148

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                RemoteImageView(url: workout.imageUrl)
                    .frame(width: Self.cardWidth, height: Self.photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)

                    Text(workout.levelDurationLabel)
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }
            .frame(width: Self.cardWidth, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

/// The full-width card the category screen stacks: the same content as `DiscoverWorkoutCard` with
/// the photo running the width of the content column.
struct DiscoverListCard: View {
    let workout: WorkoutDay
    let action: () -> Void

    private static let photoHeight: CGFloat = 180

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                RemoteImageView(url: workout.imageUrl)
                    .frame(height: Self.photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(workout.levelDurationLabel)
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

/// A row of the weekly ranking: position, thumbnail, name and its "Level · N min" caption.
struct RankedWorkoutRow: View {
    let rank: Int
    let workout: WorkoutDay
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.s) {
                Text("\(rank)")
                    .font(.custom("Didot-Bold", size: 16))
                    .foregroundStyle(Asset.Color.textSecondary.color)
                    .frame(width: 26.iPad(30), alignment: .leading)

                RemoteImageView(url: workout.imageUrl)
                    .frame(width: 88, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)

                    Text(workout.levelDurationLabel)
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
}

/// An exercise row of a workout the user has not unlocked: no name, no photo, just its position
/// and a padlock. What is being withheld is the content, not the fact that the workout has one.
struct LockedExerciseRow: View {
    let position: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.s) {
                Asset.Icon.Discover.lockBlack.image
                    .toIcon(Layout.Icon.small)
                    .frame(width: 48, height: 48)
                    .background(Asset.Color.textTertiary.color)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))

                Text("Exercise \(position)")
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

/// The "Recent" card at the top of Discover: the plan the user has under way, the day they are on,
/// and how far through the plan they are.
struct RecentPlanCard: View {
    let imageUrl: URL?
    let title: String
    let subtitle: String
    let progress: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.s) {
                RemoteImageView(url: imageUrl)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))

                VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                    Text(title)
                        .font(.custom("Didot-Bold", size: 18))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    HStack(spacing: Layout.Spacing.s) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Asset.Color.borderPrimary.color)
                                Capsule()
                                    .fill(Asset.Color.mainColor.color)
                                    .frame(width: max(geometry.size.width * progress,
                                                      progress > 0 ? 6 : 0))
                            }
                        }
                        .frame(height: 4)

                        Text("\(Int((progress * 100).rounded()))%")
                            .font(Typography.captionMedium)
                            .foregroundStyle(Asset.Color.mainColor.color)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Asset.Color.textTertiary.color)
            }
            .padding(Layout.Spacing.s)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// Back button plus a serif screen title, for the Discover screens that push without a hero photo.
struct DiscoverNavigationBar: View {
    let title: String
    let back: () -> Void

    var body: some View {
        HStack(spacing: Layout.Spacing.s) {
            Button(action: back) {
                // `Commo.arrowLeft` is a white PNG meant for the dark scrim over a hero photo; on
                // this screen's cream background it is invisible. `backChevron` is the dark one.
                Asset.Icon.ProfileSetup.backChevron.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }

            Text(title)
                .font(.custom("Didot-Bold", size: 20))
                .foregroundStyle(Asset.Color.textPrimary.color)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(height: Layout.Button.height)
        .padding(.horizontal, Layout.Spacing.m)
    }
}
