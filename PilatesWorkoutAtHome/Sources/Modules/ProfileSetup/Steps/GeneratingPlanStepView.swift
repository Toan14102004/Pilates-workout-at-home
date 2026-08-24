//
//  GeneratingPlanStepView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import SwiftUI

struct GeneratingPlanStepView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Layout.Spacing.xl) {
                VStack(spacing: Layout.Spacing.xs) {
                    Text(ProfileSetupStep.generatingPlan.title)
                        .font(.custom("Didot-Bold", size: 24))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .multilineTextAlignment(.center)

                    if let subtitle = ProfileSetupStep.generatingPlan.subtitle {
                        Text(subtitle)
                            .font(Typography.bodySmall)
                            .foregroundStyle(Asset.Color.textSecondary.color)
                            .multilineTextAlignment(.center)
                    }
                }

                ZStack {
                    Asset.Image.ProfileSetup.generatingPlanIllustration.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 151, height: 165)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))

                    ActivityIndicatorView(isVisible: .constant(true), type: .default(count: 8))
                        .foregroundColor(Asset.Color.mainColor.color)
                        .frame(width: 64, height: 64)
                }

                Text("This may take a few moments…")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.secondaryColor.color)
            }
            .padding(.horizontal, Layout.Spacing.l)

            Spacer()

            if let adKey = ProfileSetupStep.generatingPlan.compactAdKey {
                PreloadedNativeAdsView(adKey: adKey, style: .banner, height: NativeAdViewStyle.banner.height)
                    .padding(.horizontal, Layout.Spacing.m)
                    .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
    }
}
