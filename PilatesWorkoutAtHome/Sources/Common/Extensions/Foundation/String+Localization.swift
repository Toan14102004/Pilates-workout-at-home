//
//  String+Localization.swift
//  PilatesWorkoutAtHome
//
//  Created by Assistant on 9/23/25.
//

import Foundation
import SwiftUI

extension String {
    /// Converts a dynamic string (e.g. from a model) into a LocalizedStringKey
    /// so `Text(...)` re-localizes and updates when the app locale changes.
    var localizedKey: LocalizedStringKey { LocalizedStringKey(self) }

    /// Converts a localization key to its localized string value
    /// for use in TextField bindings - uses app's current language
    var localizedString: String {
        let currentLanguage = LanguageManager.shared.currentLanguageCode
        return localizedString(for: currentLanguage)
    }

    /// Converts a localization key to its localized string value for a specific language
    private func localizedString(for languageCode: String) -> String {
        // Map language codes to bundle names
        let bundleLanguageCode = switch languageCode {
        case "en-US", "en-GB", "en-CA", "en-ZA":
            "en"
        case "hi":
            "hi"
        case "ar":
            "ar"
        case "de":
            "de"
        case "ja":
            "ja"
        default:
            // Default to English for unknown language codes
            "en"
        }

        guard let path = Bundle.main.path(forResource: bundleLanguageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // For English variants or when bundle not found, return the key itself as default value
            if languageCode.hasPrefix("en") {
                return self
            }
            // For other languages, fallback to NSLocalizedString
            return NSLocalizedString(self, comment: "")
        }

        let localizedValue = bundle.localizedString(forKey: self, value: nil, table: nil)

        // If localized value is the same as key (meaning no translation found), return key for English
        if localizedValue == self, languageCode.hasPrefix("en") {
            return self
        }

        return localizedValue
    }
}
