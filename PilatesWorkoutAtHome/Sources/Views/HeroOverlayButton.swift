//
//  HeroOverlayButton.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// Small circular button floating over a hero photo — back/close/settings on the
/// Schedule, Workout Day, and Exercise Detail screens.
struct HeroOverlayButton: View {
    let image: ImageAsset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            image.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(Asset.Color.white.color)
                .padding(Layout.Spacing.s)
                .background(.black.opacity(Layout.Opacity.medium))
                .clipShape(Circle())
        }
    }
}

/// Placeholder gear glyph until the real Figma settings icon can be downloaded — a literal
/// text character (not a system image), swap for `Asset.Icon.*` once Figma access returns.
struct HeroOverlayTextButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Asset.Color.white.color)
                .frame(width: 16, height: 16)
                .padding(Layout.Spacing.s)
                .background(.black.opacity(Layout.Opacity.medium))
                .clipShape(Circle())
        }
    }
}
