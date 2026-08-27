//
//  ProfileViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

extension ProfileView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var profile = UserProfile()

        /// Re-read on every appearance: Personal Details writes straight to storage,
        /// so popping back has to pick the new name / avatar up.
        func reload() {
            profile = localStorageService.userProfile
        }

        var avatarImage: UIImage? {
            profile.avatarImageData.flatMap(UIImage.init(data:))
        }

        // MARK: - Navigation

        func openPersonalDetails() {
            navigation.push(ContentView.Coordinator.Navigation.personalDetails)
        }

        func openWorkoutSettings() {
            navigation.push(ContentView.Coordinator.Navigation.workoutSettings)
        }

        func openReminder() {
            navigation.push(ContentView.Coordinator.Navigation.reminder)
        }

        func openLanguage() {
            navigation.push(ContentView.Coordinator.Navigation.languageView)
        }

        func openPremium() {
            navigation.presentCover(
                RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .settings),
                withNavigation: true
            )
        }

        // MARK: - Links

        func rateUs() {
            let urlString = "https://apps.apple.com/app/id\(AppConfiguration.appId)?action=write-review"
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }

        func shareApp() {
            openShareView(["https://apps.apple.com/app/\(AppConfiguration.appId)"])
        }

        func openTermOfUse() {
            guard let url = URL(string: AppConfiguration.termOfUseUrl) else { return }
            UIApplication.shared.open(url)
        }

        func openPrivacyPolicy() {
            guard let url = URL(string: AppConfiguration.privacyUrl) else { return }
            UIApplication.shared.open(url)
        }
    }
}
