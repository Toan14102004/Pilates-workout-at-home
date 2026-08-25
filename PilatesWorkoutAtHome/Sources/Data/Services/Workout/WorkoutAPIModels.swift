//
//  WorkoutAPIModels.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//
//  Wire format for https://pilates-workout.limgrow.com (see /api-docs). These stay a thin
//  mirror of the JSON -- the mapping into the domain models the UI uses lives in
//  WorkoutService, so a field rename on the server touches one layer only.
//

import Foundation

// MARK: - Envelopes

/// Every endpoint wraps its payload as `{ "success": true, "data": ... }`.
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
}

/// List endpoints nest their rows one level deeper, as `{ "items": [...] }`.
struct APIItems<T: Codable>: Codable {
    let items: [T]
}

// MARK: - Programs

struct ProgramSummaryDTO: Codable {
    let programId: String
    let name: String
    let description: String?
    let level: String?
    let dayCount: Int?
    let workoutDayCount: Int?
    let restDayCount: Int?
    let coverImagePath: String?
    let categories: [String]?
    /// Added by the backend so the plan card can show "15 Min - 29 Exercises" without a second
    /// call per card.
    let durationSeconds: Int?
    let exerciseCount: Int?
}

struct ProgramDetailDTO: Codable {
    let programId: String
    let name: String
    let description: String?
    let level: String?
    let coverImageUrl: String?
    let dayCount: Int?
    let workoutDayCount: Int?
    let restDayCount: Int?
    let categories: [String]?
    let durationSeconds: Int?
    let exerciseCount: Int?
    let phases: [ProgramPhaseDTO]?
    let days: [ProgramDayDTO]?
}

struct ProgramPhaseDTO: Codable {
    let phaseNumber: Int?
    let name: String?
    let startDay: Int?
    let endDay: Int?
}

struct ProgramDayDTO: Codable {
    let dayNumber: Int
    let phaseNumber: Int?
    let title: String?
    let isRestDay: Bool?
    let workout: ProgramDayWorkoutDTO?
}

struct ProgramDayWorkoutDTO: Codable {
    let workoutId: String
    let name: String
    let level: String?
    let imageUrl: String?
    let dayNumber: Int?
    let durationSeconds: Int?
    let durationMinutes: Int?
    let exerciseCount: Int?
    let categories: [String]?
    let calories: Double?
}

// MARK: - Workouts

struct WorkoutDetailDTO: Codable {
    let id: String
    let name: String
    let description: String?
    let level: String?
    let dayNumber: Int?
    let estimatedDurationSeconds: Int?
    let exerciseCount: Int?
    let imagePath: String?
    let categories: [String]?
    let calories: Double?
    let exercises: [WorkoutExerciseItemDTO]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, level, dayNumber, estimatedDurationSeconds
        case exerciseCount, imagePath, categories, calories, exercises
    }
}

/// One row of a workout's ordered exercise list. `nameSnapshot`/`videoUrlSnapshot` are the
/// server's copy-at-import-time values and are what the list should render -- the nested
/// `exercise` object can be missing or lag behind.
struct WorkoutExerciseItemDTO: Codable {
    let order: Int
    let exercise: WorkoutExerciseRefDTO?
    let nameSnapshot: String?
    let duration: Int?
    let unit: String?
    let restSeconds: Int?
    let videoUrlSnapshot: String?
}

/// The nested exercise can arrive either expanded (an object) or as a bare id string,
/// depending on the endpoint, so decoding handles both shapes.
struct WorkoutExerciseRefDTO: Codable {
    let id: String
    let name: String?
    let introduction: String?
    let level: Int?
    let playableVideoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, introduction, level, playableVideoUrl
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let raw = try? single.decode(String.self) {
            id = raw
            name = nil
            introduction = nil
            level = nil
            playableVideoUrl = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        introduction = try container.decodeIfPresent(String.self, forKey: .introduction)
        level = try container.decodeIfPresent(Int.self, forKey: .level)
        playableVideoUrl = try container.decodeIfPresent(String.self, forKey: .playableVideoUrl)
    }
}

// MARK: - Exercise detail

struct ExerciseDetailDTO: Codable {
    let exerciseId: String
    let name: String
    let introduction: String?
    let level: Int?
    let instructions: ExerciseInstructionsDTO?
    let media: ExerciseMediaDTO?
    let calories: ExerciseCaloriesDTO?
    let referenceVideoUrl: String?
}

struct ExerciseInstructionsDTO: Codable {
    let howTo: [String]?
    let commonMistakes: [String]?
    let breathingTips: [String]?
    let benefits: [String]?
    let otherTips: [String]?
}

struct ExerciseMediaDTO: Codable {
    let imageUrl: String?
    let thumbnailUrl: String?
    let videoUrl: String?
    let hasImage: Bool?
    let hasVideo: Bool?
}

struct ExerciseCaloriesDTO: Codable {
    let perSecond: Double?
    let man: Double?
    let woman: Double?
}

// MARK: - Discover

struct DiscoverDTO: Codable {
    let sections: [DiscoverSectionDTO]?
    let weeklyTop: [DiscoverItemDTO]?
    let weeklyTopTotal: Int?
}

struct DiscoverSectionDTO: Codable {
    let sectionId: Int
    let title: String
    let displayOrder: Int?
    let totalItems: Int?
    let items: [DiscoverItemDTO]?
}

/// `/workouts/discover/sections/{id}` -- one section's full, paged list.
struct DiscoverSectionPageDTO: Codable {
    let items: [DiscoverItemDTO]?
    let page: Int?
    let limit: Int?
    let totalItems: Int?
    let totalPages: Int?
}

struct DiscoverItemDTO: Codable {
    let workoutId: String
    let name: String
    let description: String?
    let level: String?
    let imageUrl: String?
    let durationSeconds: Int?
    let durationMinutes: Int?
    let exerciseCount: Int?
    let calories: Double?
    let rank: Int?
}
