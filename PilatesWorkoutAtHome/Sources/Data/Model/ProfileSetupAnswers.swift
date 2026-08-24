//
//  ProfileSetupAnswers.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 21/8/26.
//

import Foundation

enum HeightUnit: String, Codable {
    case centimeters
    case feetInches
}

enum WeightUnit: String, Codable {
    case kilograms
    case pounds
}

struct ProfileSetupAnswers: Codable, Equatable {
    var motivation: String?
    var primaryGoal: String?

    var heightUnit: HeightUnit = .centimeters
    var heightCm: Int?

    var weightUnit: WeightUnit = .kilograms
    var currentWeightKg: Double?
    var targetWeightKg: Double?

    var age: Int?

    var workoutLocation: String?
    var preferredActivities: [String] = []
    var experienceLevel: String?
    var workoutIntensity: String?
    var injuredAreas: [String] = []
    var currentRole: String?
    var dailyActivityLevel: String?
    var fitnessLevel: String?
}
