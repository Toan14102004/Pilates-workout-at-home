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
    var phases: [WorkoutPhase]

    var days: [WorkoutDay] { phases.flatMap(\.days) }

    var totalDays: Int { dayCount > 0 ? dayCount : days.count }

    var firstWorkoutDay: WorkoutDay? { days.first { !$0.isRestDay } }

    /// The design shows duration and exercise count as two separate items. Both come from the
    /// program's first workout day, which only `/workout-programs/{id}` returns -- the list
    /// endpoint has no duration or exercise count, so these are nil until the detail is loaded.
    var durationText: String? { firstWorkoutDay.map { "\($0.netDurationMinutes) Min" } }

    var exercisesText: String? { firstWorkoutDay.map { "\($0.displayExerciseCount) Exercises" } }

    var fallbackText: String { "\(totalDays) Days" }

    var subtitleLabel: String {
        guard let durationText, let exercisesText else { return fallbackText }
        return "\(durationText) · \(exercisesText)"
    }
}
