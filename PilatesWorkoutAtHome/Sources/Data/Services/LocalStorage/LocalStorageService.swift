//
//  LocalStorageService.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 18/11/24.
//

import Foundation

protocol UserDefaultService: AnyObject {
    // App flags
    var isFirstTimeOpenApp: Bool { get set }
    var isFirstTimeUsingApp: Bool { get set }
    
    // Subscription
    var weeklyFreeTrialEnabled: Bool { get set }
    var monthlyFreeTrialEnabled: Bool { get set }
    var yearlyFreeTrialEnabled: Bool { get set }
    
    // Global Ad Config
    var isDisplayPremiumAfterSplash: Bool { get set }
    var isDisplayLanguageAfterSplash: Bool { get set }
    var distanceCountShowInterShare: Int { get set }
    var distanceTimeShowOtherAds: Int { get set }
    var distanceTimeShowSameAds: Int { get set }
    
    // PilatesWorkoutAtHome - Inter
    var foodInterSplash: AdPlacement { get set }
    var foodInterSplashHight: AdPlacement { get set }
    var foodInterShare: AdPlacement { get set }
    var foodInterShareHight: AdPlacement { get set }
    
    // PilatesWorkoutAtHome - Native
    var foodNativeLanguage: AdPlacement { get set }
    var foodNativeLanguageClick: AdPlacement { get set }
    var foodNativeLanguageClickHight: AdPlacement { get set }
    var foodNativeLanguageHight: AdPlacement { get set }
    var profileSetupCompactAd: AdPlacement { get set }
    var profileSetupMediumAd: AdPlacement { get set }
    var practiceCompactAd: AdPlacement { get set }

    // API Configuration
    var foodScanBaseURL: String { get set }

    // PilatesWorkoutAtHome - Limit
    // var countIdentityScan: Int { get set }
    var maxFreeIdentityScan: Int { get set }

    // Profile Setup
    var profileSetupAnswers: ProfileSetupAnswers { get set }

    // Practice / Workout progress
    var workoutSettings: WorkoutSettings { get set }
    var completedExerciseIds: [String] { get set }
    var completedWorkoutIds: [String] { get set }
    var currentWorkoutDayId: String? { get set }
    var currentProgramId: String? { get set }
}

private enum Keys {
    // App flags
    static let isFirstTimeOpenApp = "isFirstTimeOpenApp"
    static let isFirstTimeUsingApp = "isFirstTimeUsingApp"
    
    // Subscription
    static let monthlyFreeTrialEnabled = "monthly_free_trial_enabled"
    static let weeklyFreeTrialEnabled = "weekly_free_trial_enabled"
    static let yearlyFreeTrialEnabled = "yearly_free_trial_enabled"
    
    // Global Ad Config
    static let isDisplayPremiumAfterSplash = "isDisplayPremiumAfterSplash"
    static let isDisplayLanguageAfterSplash = "is_display_language_after_splash"
    static let distanceCountShowInterShare = "distance_count_show_inter_share"
    static let distanceTimeShowOtherAds = "distance_time_show_other_ads"
    static let distanceTimeShowSameAds = "distance_time_show_same_ads"
    
    // PilatesWorkoutAtHome - Inter
    static let foodInterSplash = "food_inter_splash"
    static let foodInterSplashHight = "food_inter_splash_high"
    static let foodInterShare = "food_inter_share"
    static let foodInterShareHight = "food_inter_share_high"
    
    // PilatesWorkoutAtHome - Native
    static let foodNativeLanguage = "food_native_language"
    static let foodNativeLanguageHight = "food_native_language_high"
    static let foodNativeLanguageClick = "food_native_language_click"
    static let foodNativeLanguageClickHight = "food_native_language_click_high"
    static let profileSetupCompactAd = "profile_setup_compact_ad"
    static let profileSetupMediumAd = "profile_setup_medium_ad"
    static let practiceCompactAd = "practice_compact_ad"

    // API Configuration
    static let foodScanBaseURL = "food_scan_base_url"

    // PilatesWorkoutAtHome - Limit
    static let maxFreeIdentityScan = "max_free_identity_scan"

    // Profile Setup
    static let profileSetupAnswers = "profile_setup_answers"

    // Practice / Workout progress
    static let workoutSettings = "workout_settings"
    static let completedExerciseIds = "completed_exercise_ids"
    static let completedWorkoutIds = "completed_workout_ids"
    static let currentWorkoutDayId = "current_workout_day_id"
    static let currentProgramId = "current_program_id"
}

class LocalStorageService: UserDefaultService {
    static let shared = LocalStorageService()
    
    @ObjectUserDefaultWrapper(key: Keys.isFirstTimeOpenApp, defaultValue: true)
    var isFirstTimeOpenApp: Bool
    
    @ObjectUserDefaultWrapper(key: Keys.isFirstTimeUsingApp, defaultValue: true)
    var isFirstTimeUsingApp: Bool
    
    // MARK: - Subscription
    @UserDefaultWrapper(key: Keys.weeklyFreeTrialEnabled, defaultValue: true)
    var weeklyFreeTrialEnabled: Bool
    
    @UserDefaultWrapper(key: Keys.monthlyFreeTrialEnabled, defaultValue: false)
    var monthlyFreeTrialEnabled: Bool
    
    @UserDefaultWrapper(key: Keys.yearlyFreeTrialEnabled, defaultValue: false)
    var yearlyFreeTrialEnabled: Bool
    
    // MARK: Global Ad config
    @ObjectUserDefaultWrapper(key: Keys.isDisplayPremiumAfterSplash, defaultValue: true)
    var isDisplayPremiumAfterSplash: Bool
    
    @UserDefaultWrapper(key: Keys.isDisplayLanguageAfterSplash, defaultValue: true)
    var isDisplayLanguageAfterSplash: Bool
    
    @UserDefaultWrapper(key: Keys.distanceCountShowInterShare, defaultValue: 3)
    var distanceCountShowInterShare: Int
    
    @UserDefaultWrapper(key: Keys.distanceTimeShowOtherAds, defaultValue: 20)
    var distanceTimeShowOtherAds: Int
    
    @UserDefaultWrapper(key: Keys.distanceTimeShowSameAds, defaultValue: 20)
    var distanceTimeShowSameAds: Int
    
    // MARK: - API Configuration
    @UserDefaultWrapper(
        key: Keys.foodScanBaseURL, defaultValue: "https://pilates-workout.limgrow.com")
    var foodScanBaseURL: String
    
    // MARK: - PilatesWorkoutAtHome Ad Placements
    
    // Inter
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterSplash,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterSplash: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterSplashHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterSplashHight: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterShare,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterShare: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodInterShareHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/1033173712", isEnabled: true)
    )
    var foodInterShareHight: AdPlacement
    
    // Inter
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguage,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguage: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguageHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguageHight: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguageClick,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguageClick: AdPlacement
    
    @ObjectUserDefaultWrapper(
        key: Keys.foodNativeLanguageClickHight,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var foodNativeLanguageClickHight: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.profileSetupCompactAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var profileSetupCompactAd: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.profileSetupMediumAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var profileSetupMediumAd: AdPlacement

    @ObjectUserDefaultWrapper(
        key: Keys.practiceCompactAd,
        defaultValue: AdPlacement(id: "ca-app-pub-3940256099942544/2247696110", isEnabled: true)
    )
    var practiceCompactAd: AdPlacement

    // MARK: - PilatesWorkoutAtHome Limit
    @UserDefaultWrapper(key: Keys.maxFreeIdentityScan, defaultValue: 3)
    var maxFreeIdentityScan: Int

    // MARK: - Profile Setup
    @ObjectUserDefaultWrapper(key: Keys.profileSetupAnswers, defaultValue: ProfileSetupAnswers())
    var profileSetupAnswers: ProfileSetupAnswers

    // MARK: - Practice / Workout progress
    @ObjectUserDefaultWrapper(key: Keys.workoutSettings, defaultValue: WorkoutSettings())
    var workoutSettings: WorkoutSettings

    @ObjectUserDefaultWrapper(key: Keys.completedExerciseIds, defaultValue: [])
    var completedExerciseIds: [String]

    @ObjectUserDefaultWrapper(key: Keys.completedWorkoutIds, defaultValue: [])
    var completedWorkoutIds: [String]

    @ObjectUserDefaultWrapper(key: Keys.currentWorkoutDayId, defaultValue: nil)
    var currentWorkoutDayId: String?

    @ObjectUserDefaultWrapper(key: Keys.currentProgramId, defaultValue: nil)
    var currentProgramId: String?
}
