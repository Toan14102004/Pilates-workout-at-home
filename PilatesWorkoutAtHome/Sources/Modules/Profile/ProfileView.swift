//
//  ProfileView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// Figma: FLow Profile / 01 — Profile Overview. Rendered as the root of the Profile tab,
/// so the back chevron in the design frame is intentionally dropped here.
struct ProfileView: View {
    @StateObject var viewModel = ViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavBar(title: "Profile") {
                streakPill
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: Layout.Spacing.xl) {
                    identity

                    VStack(spacing: Layout.Spacing.m) {
                        if !subscriptionManager.isSubscribed {
                            PremiumAccessCard(action: viewModel.openPremium)
                        }

                        PreloadedNativeAdsView(adKey: .profileMedium, style: .medium, height: NativeAdViewStyle.medium.height)

                        ProfileMenuCard {
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuProfile.image, title: "My Profile", action: viewModel.openPersonalDetails)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuWorkoutSettings.image, title: "Workout Settings", action: viewModel.openWorkoutSettings)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuReminder.image, title: "Reminder", action: viewModel.openReminder)
                        }

                        ProfileMenuCard {
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuRateUs.image, title: "Rate Us", action: viewModel.rateUs)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuLanguage.image, title: "Language", action: viewModel.openLanguage)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuInviteFriends.image, title: "Invite Friends", action: viewModel.shareApp)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuTerms.image, title: "Terms of Use", action: viewModel.openTermOfUse)
                            ProfileMenuRow(icon: Asset.Icon.Profile.menuPrivacy.image, title: "Privacy Policy", action: viewModel.openPrivacyPolicy)
                        }
                    }
                    .padding(.horizontal, Layout.Spacing.m)
                }
                .padding(.bottom, Layout.Spacing.xxl * 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .onAppear(perform: viewModel.reload)
        .trackScreen("profileVC")
    }

    // MARK: - Pieces

    private var streakPill: some View {
        HStack(spacing: Layout.Spacing.s) {
            Asset.Icon.Profile.fireStreak.image
                .resizable()
                .frame(width: 24, height: 24)

            Text("\(viewModel.profile.streakCount)")
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.mainColor.color)
        }
        .padding(.horizontal, Layout.Spacing.s)
        .padding(.vertical, Layout.Spacing.xxs)
        .background(Asset.Color.white.color)
        .clipShape(Capsule())
    }

    private var identity: some View {
        VStack(spacing: Layout.Spacing.s) {
            Group {
                if let image = viewModel.avatarImage {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                } else {
                    Asset.Icon.Profile.avatarPlaceholder.image.resizable().aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            Text(viewModel.profile.displayName)
                .font(.custom("Didot-Bold", size: 32))
                .foregroundStyle(Asset.Color.textPrimary.color)
        }
        .padding(.top, Layout.Spacing.m)
    }
}

#Preview {
    ProfileView()
        .preview()
}
