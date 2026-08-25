//
//  WorkoutPlan.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutPlan: Identifiable {
    /// The API's programId.
    let id: String
    let title: String
    let subtitle: String
    let level: String
    let coverImageUrl: URL?
    let dayCount: Int
    /// Straight from the list endpoint, so the card needs no follow-up request.
    let durationSeconds: Int
    let exerciseCount: Int
    var phases: [WorkoutPhase]

    var days: [WorkoutDay] { phases.flatMap(\.days) }

    var totalDays: Int { dayCount > 0 ? dayCount : days.count }

    var firstWorkoutDay: WorkoutDay? { days.first { !$0.isRestDay } }

    /// The design shows duration and exercise count as two separate items.
    var durationText: String? {
        guard durationSeconds > 0 else { return firstWorkoutDay.map { "\($0.netDurationMinutes) Min" } }
        return "\(Int((Double(durationSeconds) / 60).rounded(.up))) Min"
    }

    var exercisesText: String? {
        guard exerciseCount > 0 else { return firstWorkoutDay.map { "\($0.displayExerciseCount) Exercises" } }
        return "\(exerciseCount) Exercises"
    }

    var fallbackText: String { "\(totalDays) Days" }

    var subtitleLabel: String {
        guard let durationText, let exercisesText else { return fallbackText }
        return "\(durationText) · \(exercisesText)"
    }
}
