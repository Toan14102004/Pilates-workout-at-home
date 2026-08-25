//
//  WorkoutDay.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutDay: Identifiable, Equatable {
    /// The API's workoutId -- this is what `/workouts/{id}` and the progress endpoints key on.
    let id: String
    let dayNumber: Int
    /// Which program phase this day belongs to, when the program defines phases.
    let phaseNumber: Int?
    let planName: String
    let title: String
    let level: String
    let isRestDay: Bool
    let imageUrl: URL?
    /// The server's own estimate, authoritative even before the exercise list is loaded.
    let durationSeconds: Int
    let exerciseCount: Int
    /// Only the Discover/weekly-top endpoints carry calories; a program day does not, so this is
    /// nil there and the UI hides the stat rather than inventing a number.
    let kcal: Double?
    /// Empty until `/workouts/{id}` has been fetched for this day.
    var exercises: [WorkoutExercise]

    var isLoaded: Bool { !exercises.isEmpty }

    var netDurationSeconds: Int {
        durationSeconds > 0 ? durationSeconds : exercises.reduce(0) { $0 + $1.durationSeconds }
    }

    var netDurationMinutes: Int { Int((Double(netDurationSeconds) / 60).rounded(.up)) }

    var displayExerciseCount: Int { isLoaded ? exercises.count : exerciseCount }

    var exerciseCountLabel: String { "\(netDurationMinutes) min · \(displayExerciseCount) exercises" }

    static func == (lhs: WorkoutDay, rhs: WorkoutDay) -> Bool {
        lhs.id == rhs.id && lhs.exercises.count == rhs.exercises.count
    }
}
