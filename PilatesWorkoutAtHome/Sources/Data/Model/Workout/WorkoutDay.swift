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
    /// The workout's own blurb. Only the Discover feed and `/workouts/{id}` carry one; a program
    /// day summary does not, so this is empty there and the UI drops the paragraph.
    let summary: String
    let level: String
    let isRestDay: Bool
    let imageUrl: URL?
    /// The server's own estimate, authoritative even before the exercise list is loaded.
    let durationSeconds: Int
    let exerciseCount: Int
    /// Only the Discover/weekly-top endpoints carry calories; a program day does not, so this is
    /// nil there and the UI hides the stat rather than inventing a number.
    let kcal: Double?
    /// Position in the weekly ranking. Only the weekly-top endpoints supply it.
    let rank: Int?
    /// Empty until `/workouts/{id}` has been fetched for this day.
    var exercises: [WorkoutExercise]

    var isLoaded: Bool { !exercises.isEmpty }

    var netDurationSeconds: Int {
        durationSeconds > 0 ? durationSeconds : exercises.reduce(0) { $0 + $1.durationSeconds }
    }

    var netDurationMinutes: Int { Int((Double(netDurationSeconds) / 60).rounded(.up)) }

    var displayExerciseCount: Int { isLoaded ? exercises.count : exerciseCount }

    var exerciseCountLabel: String { "\(netDurationMinutes) min · \(displayExerciseCount) exercises" }

    /// "Intermediate · 17 min" -- the caption under every Discover card and ranking row. Workouts
    /// the API ships without a level fall back to the duration alone rather than a stray separator.
    var levelDurationLabel: String {
        let duration = "\(netDurationMinutes) min"
        return level.isEmpty ? duration : "\(level) · \(duration)"
    }

    static func == (lhs: WorkoutDay, rhs: WorkoutDay) -> Bool {
        lhs.id == rhs.id && lhs.exercises.count == rhs.exercises.count
    }
}
