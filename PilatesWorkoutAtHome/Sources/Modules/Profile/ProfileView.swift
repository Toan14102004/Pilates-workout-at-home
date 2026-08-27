//
//  ProfileView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

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

                        PreloadedNativeAdsView(adKey: .profileMedium, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

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
        Button(action: viewModel.openStreak) {
            HStack(spacing: Layout.Spacing.s) {
                Asset.Icon.Commo.fire.image.toIcon(Layout.Icon.medium)

                Text("\(viewModel.streakDays)")
            }
            .font(Typography.bodyLarge)
            .foregroundStyle(Asset.Color.mainColor.color)
            .padding(.horizontal, Layout.Spacing.s)
            .padding(.vertical, Layout.Spacing.xs)
            .background(Asset.Color.white.color, in: Capsule())
            .overlay(Capsule().stroke(Asset.Color.mainColor.color, lineWidth: 1))
        }
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
