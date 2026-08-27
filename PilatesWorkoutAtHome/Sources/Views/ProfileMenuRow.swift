//
//  ProfileMenuRow.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// One 64pt row of the Profile tab's menu cards: tinted 40pt icon tile, label, chevron.
struct ProfileMenuRow: View {
    let icon: Image
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Asset.Color.secondaryColor.color)
                    .frame(width: 24, height: 24)
                    .padding(Layout.Spacing.s)
                    .background(Asset.Color.iconSurface.color)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))

                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Asset.Icon.Profile.chevronRight.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.vertical, Layout.Spacing.s + Layout.Spacing.xs)
        }
        .buttonStyle(.plain)
    }
}

/// Groups menu rows into one white 16pt-radius card, matching the two stacks in the design.
struct ProfileMenuCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, Layout.Spacing.m)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }
}
