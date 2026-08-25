//
//  WorkoutProgressStore.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

/// Owns which exercises and workouts the user has finished.
///
/// Progress is written locally first so the UI reacts immediately and keeps working offline --
/// which matters for an app used mid-workout. The shape deliberately mirrors what
/// `PUT /workouts/{id}/progress` expects (exercise `order`s, and an elapsed count that excludes
/// paused and backgrounded time), so pushing to the server later is a transport change rather
/// than a rewrite.
///
/// Values are read through to `LocalStorageService` on every access instead of being cached in
/// `@Published` properties: this type is built by `Dependencies.build()`, and resolving another
/// dependency from `init` runs before the container is ready and traps.
final class WorkoutProgressStore: ObservableObject {
    @Injected var localStorageService: LocalStorageService

    var completedExerciseIds: Set<String> { Set(localStorageService.completedExerciseIds) }

    var completedWorkoutIds: Set<String> { Set(localStorageService.completedWorkoutIds) }

    func isExerciseCompleted(_ id: String) -> Bool {
        localStorageService.completedExerciseIds.contains(id)
    }

    func isWorkoutCompleted(_ id: String) -> Bool {
        localStorageService.completedWorkoutIds.contains(id)
    }

    /// How far through a workout the user is, for the day-level progress bar.
    func completedCount(in exercises: [WorkoutExercise]) -> Int {
        let completed = completedExerciseIds
        return exercises.filter { completed.contains($0.id) }.count
    }

    func markExerciseCompleted(_ exercise: WorkoutExercise, in workoutId: String) {
        guard !isExerciseCompleted(exercise.id) else { return }
        objectWillChange.send()
        localStorageService.completedExerciseIds.append(exercise.id)
        localStorageService.workoutCompletedCounts[workoutId, default: 0] += 1
    }

    /// How far through a day the user got, for the per-day bar on the schedule. Days that were
    /// never started report 0, finished days report 1.
    func progressFraction(workoutId: String, exerciseCount: Int) -> Double {
        if isWorkoutCompleted(workoutId) { return 1 }
        guard exerciseCount > 0,
              let done = localStorageService.workoutCompletedCounts[workoutId] else { return 0 }
        return min(Double(done) / Double(exerciseCount), 1)
    }

    /// Called when every exercise in a workout has been finished. `elapsedSeconds` is kept for the
    /// progress payload the server will eventually receive.
    func markWorkoutCompleted(workoutId: String, elapsedSeconds _: Int) {
        guard !isWorkoutCompleted(workoutId) else { return }
        objectWillChange.send()
        localStorageService.completedWorkoutIds.append(workoutId)
    }

    /// Clears one workout's progress -- the "Restart" action on the Workout Day screen.
    func reset(workoutId: String, exercises: [WorkoutExercise]) {
        let ids = Set(exercises.map(\.id))
        objectWillChange.send()
        localStorageService.completedExerciseIds.removeAll { ids.contains($0) }
        localStorageService.completedWorkoutIds.removeAll { $0 == workoutId }
        localStorageService.workoutCompletedCounts[workoutId] = nil
    }
}
