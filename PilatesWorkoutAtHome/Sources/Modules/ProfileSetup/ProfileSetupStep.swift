//
//  ProfileSetupStep.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import Foundation

enum ProfileSetupStep: Int, CaseIterable {
    case motivation
    case primaryGoal
    case height
    case currentWeight
    case targetWeight
    case age
    case workoutLocation
    case preferredActivities
    case experienceLevel
    case workoutIntensity
    case injuredAreas
    case currentRole
    case dailyActivityLevel
    case fitnessLevel
    case generatingPlan

    static let quizStepCount = ProfileSetupStep.allCases.count - 1 // excludes generatingPlan

    var progressLabel: String { "\(rawValue + 1)/\(Self.quizStepCount)" }

    var progress: Double {
        Double(rawValue + 1) / Double(Self.quizStepCount)
    }

    var title: String {
        switch self {
        case .motivation: "What motivates you the most?"
        case .primaryGoal: "What's your main goal?"
        case .height: "What's your height?"
        case .currentWeight: "What's your weight?"
        case .targetWeight: "What's your target weight?"
        case .age: "What's your age?"
        case .workoutLocation: "Where do you typically work out?"
        case .preferredActivities: "What activities do you enjoy?"
        case .experienceLevel, .workoutIntensity: "What's your preferred workout level?"
        case .injuredAreas: "Any injured areas needing attention"
        case .currentRole: "Which describes your current role?"
        case .dailyActivityLevel: "What does your typical day look like?"
        case .fitnessLevel: "What's your fitness level?"
        case .generatingPlan: "Your Personalized Pilates Plan"
        }
    }

    var subtitle: String? {
        switch self {
        case .age: "It'll help us personalize your to better suit your age group."
        case .injuredAreas: "We will filter and reduce improper exercises for you"
        case .generatingPlan: "We're putting together a routine based on your goals, experience, and preferences."
        default: nil
        }
    }

    var showsBackButton: Bool { self != .motivation }

    var isLastQuizStep: Bool { self == .fitnessLevel }

    /// Options for the single/multi-select list steps. Empty for the custom numeric/loading steps.
    var options: [String] {
        switch self {
        case .motivation:
            ["Get in shape", "Look Better", "Reduce Stress & Relax", "Sleep Better", "Find Self-Love"]
        case .primaryGoal:
            ["Lose Weight", "Tone Muscles", "Improve Heathy", "Improve Flexibility", "Refine Posture"]
        case .workoutLocation:
            ["On the Mat", "On the Bed/Sofa", "Any place is fine"]
        case .preferredActivities:
            ["General Fitness", "Wall Pilates", "Calisthenics", "Stretching", "Yoga", "Dancing", "Recovery"]
        case .experienceLevel:
            ["No experience", "Less than 1 year", "1-3 years", "3+ years"]
        case .workoutIntensity:
            ["Easy to start", "Break a light sweat", "A bit challenging"]
        case .injuredAreas:
            ["None of them", "Knee", "Lower back", "Shoulder", "Ankle", "Wrist"]
        case .currentRole:
            [
                "I'm a student", "I'm a full-time worker", "I'm a part-time worker", "I'm a freelancer",
                "I'm focusing on home and family life", "I'm running my own business",
                "I'm working shifts or irregular hours", "I'm pursuing new chances or on a break",
                "I'm entering a new phase of life", "Other",
            ]
        case .dailyActivityLevel:
            ["At work, mostly sitting", "At home, mostly inactive", "Walking every day", "At work, mostly standing"]
        case .fitnessLevel:
            ["Beginner", "Intermediate", "Advanced"]
        case .height, .currentWeight, .targetWeight, .age, .generatingPlan:
            []
        }
    }

    /// "None of them"-style option that clears every other selection in a multi-select step.
    var exclusiveOption: String? {
        self == .injuredAreas ? "None of them" : nil
    }

    var compactAdKey: AdsPreloadService.AdsPreloadKey? {
        switch self {
        case .height, .currentWeight, .generatingPlan: .profileSetupCompact
        default: nil
        }
    }

    var mediumAdKey: AdsPreloadService.AdsPreloadKey? {
        switch self {
        case .workoutLocation, .experienceLevel, .workoutIntensity, .dailyActivityLevel, .fitnessLevel: .profileSetupMedium
        default: nil
        }
    }
}
