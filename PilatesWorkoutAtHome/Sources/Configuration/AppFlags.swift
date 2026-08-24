//
//  AppFlags.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 22/8/26.
//

import Foundation

/// Single, code-level place to flip Ads/IAP behavior on or off — no remote server involved.
/// Backed by the same local `KeychainStorage`/`LocalStorageService` values every ad/IAP call
/// site already reads; this just gives one obvious switch instead of hunting through those
/// services' many properties.
enum AppFlags {
    /// Master switch for all ad surfaces (native, interstitial, rewarded, app-open).
    static var adsEnabled: Bool {
        get { KeychainStorage.shared.adsEnabled }
        set { KeychainStorage.shared.adsEnabled = newValue }
    }

    /// Master switch for IAP free-trial eligibility.
    static var iapTrialEnabled: Bool {
        get { LocalStorageService.shared.weeklyFreeTrialEnabled }
        set { LocalStorageService.shared.weeklyFreeTrialEnabled = newValue }
    }
}
