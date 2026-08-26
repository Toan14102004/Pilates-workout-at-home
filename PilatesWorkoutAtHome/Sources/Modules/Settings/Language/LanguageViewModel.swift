//
//  LanguageViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 15/10/25.
//

import Foundation
import SwiftUI
import Combine
import FlagAndCountryCode

struct Language: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let countryCode: String
    let flagAsset: ImageAsset?
    let flagEmoji: String?

    init(code: String, name: String, countryCode: String, flagAsset: ImageAsset) {
        self.code = code
        self.name = name
        self.countryCode = countryCode
        self.flagAsset = flagAsset
        self.flagEmoji = nil
    }

    init(code: String, name: String, countryCode: String, flagEmoji: String) {
        self.code = code
        self.name = name
        self.countryCode = countryCode
        self.flagAsset = nil
        self.flagEmoji = flagEmoji
    }

    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.code == rhs.code
    }

    // Keep this order aligned with the Language frames in Figma.
    static let supportedLanguages: [Language] = [
        Language(code: "ko", name: "Korean", countryCode: "KR", flagAsset: Asset.Icon.Language.korea),
        Language(code: "ja", name: "Japan", countryCode: "JP", flagAsset: Asset.Icon.Language.japanese),
        Language(code: "fr", name: "French", countryCode: "FR", flagAsset: Asset.Icon.Language.french),
        Language(code: "ru", name: "Russian", countryCode: "RU", flagEmoji: "🇷🇺"),
        Language(code: "es", name: "Spanish", countryCode: "ES", flagAsset: Asset.Icon.Language.spanish),
        Language(code: "hi", name: "Hindi", countryCode: "IN", flagAsset: Asset.Icon.Language.hindi),
        Language(code: "en", name: "English", countryCode: "US", flagAsset: Asset.Icon.Language.english)
    ]
}

extension LanguageView {
    class ViewModel: BaseViewModel {

        @Navigation var navigator
        @Injected var keychainStorage: KeychainStorage
        @Injected var localStorageService: LocalStorageService
        @Injected var adsPreloadService: AdsPreloadService
        
        @Published var coordinator = Coordinator()
        @Published var languages: [Language] = Language.supportedLanguages
        @Published var selectedLanguage: Language?
        @Published var initialLanguage: Language
        @Published var hasLanguageChanged: Bool = false
        @Published var showClickAd: Bool = false
        
        let isOnboardingContext: Bool
        
        init(isOnboardingContext: Bool = false) {
            self.isOnboardingContext = isOnboardingContext
            
            let currentCode = LanguageManager.shared.currentLanguageCode
            let defaultLanguage = Language.supportedLanguages.first { $0.code == currentCode } ?? Language.supportedLanguages.first { $0.code == "en" } ?? Language.supportedLanguages[0]
            self.initialLanguage = defaultLanguage
            
            if isOnboardingContext {
                self.selectedLanguage = nil
                hasLanguageChanged = false 
            } else {
                self.selectedLanguage = defaultLanguage
                hasLanguageChanged = false  
            }
        }
        
        func goBack() {
            navigator.pop()
        }
        
        func selectLanguage(_ language: Language) {
            selectedLanguage = language
            hasLanguageChanged = true
            // Reload native ad if needed
            if showClickAd {
                let adKey: AdsPreloadService.AdsPreloadKey = .languageClick
                if let preloadedViewModel = adsPreloadService.getPreloadedAd(for: adKey),
                   !preloadedViewModel.isLoading {
                    print("[LanguageViewModel] Reloading ad \(adKey) on language selection")
                    preloadedViewModel.refreshAd()
                }
            }
            showClickAd = true
        }
        
        func confirmLanguageChange() {
            guard hasLanguageChanged, let selectedLanguage = selectedLanguage else { return }
            keychainStorage.currentLanguageCode = selectedLanguage.code
            LanguageManager.shared.changeLanguage(selectedLanguage.code)
            if isOnboardingContext {
                navigator.push(RootView.Coordinator.Navigation.onboarding)
            } else {
                navigator.pop()
            }
        }
    }
}
