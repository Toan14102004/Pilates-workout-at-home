//
//  ProfileSetupOptionCell.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct ProfileSetupOptionCell: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(isSelected ? Asset.Color.white.color : Asset.Color.textPrimary.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, Layout.Spacing.l)
                .padding(.horizontal, Layout.Spacing.m)
                .background(isSelected ? Asset.Color.secondaryColor.color : Asset.Color.white.color)
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                        .stroke(Asset.Color.optionBorder.color, lineWidth: isSelected ? 0 : Layout.StrokeWidth.thin)
                }
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Layout.Spacing.s) {
        ProfileSetupOptionCell(title: "Get in shape", isSelected: false, action: {})
        ProfileSetupOptionCell(title: "Look Better", isSelected: true, action: {})
    }
    .padding()
    .background(Asset.Color.bgPrimary.color)
}
