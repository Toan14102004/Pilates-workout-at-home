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
    @Injected var workoutService: WorkoutService
    @Injected var deviceRegistration: DeviceRegistrationService

    private var cancellables = Set<AnyCancellable>()

    var completedWorkoutIds: Set<String> { Set(localStorageService.completedWorkoutIds) }

    /// Completion is asked per workout, never per exercise alone: the API reuses one `exerciseId`
    /// across many workouts, so finishing it in one says nothing about the others.
    func isExerciseCompleted(_ exerciseId: String, in workoutId: String) -> Bool {
        localStorageService.completedExerciseIds[workoutId]?.contains(exerciseId) ?? false
    }

    func isWorkoutCompleted(_ id: String) -> Bool {
        localStorageService.completedWorkoutIds.contains(id)
    }

    /// How far through a workout the user is, for the day-level progress bar.
    func completedCount(in exercises: [WorkoutExercise], workoutId: String) -> Int {
        let completed = Set(localStorageService.completedExerciseIds[workoutId] ?? [])
        return exercises.filter { completed.contains($0.id) }.count
    }

    func markExerciseCompleted(_ exercise: WorkoutExercise, in workoutId: String) {
        guard !isExerciseCompleted(exercise.id, in: workoutId) else { return }
        objectWillChange.send()
        localStorageService.completedExerciseIds[workoutId, default: []].append(exercise.id)
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

    /// Called when every exercise in a workout has been finished. Progress is recorded locally
    /// first -- the UI reacts immediately either way -- then pushed to the server best-effort:
    /// completing a workout there also files a matching activity, which is what makes the
    /// Progress tab's calorie ring, weekly charts and "Exercises" card have anything to show.
    /// A failed push is not surfaced; the local record already stands and the next completed
    /// workout will try again.
    func markWorkoutCompleted(workoutId: String, exercises: [WorkoutExercise], elapsedSeconds: Int) {
        guard !isWorkoutCompleted(workoutId) else { return }
        objectWillChange.send()
        localStorageService.completedWorkoutIds.append(workoutId)

        let startedAt = Date().addingTimeInterval(-Double(elapsedSeconds))
        deviceRegistration.registerIfNeeded()
            .flatMap { [workoutService, deviceRegistration] in
                workoutService.saveProgress(workoutId: workoutId,
                                            deviceId: deviceRegistration.deviceId,
                                            completedExerciseOrders: exercises.map(\.order),
                                            elapsedSeconds: elapsedSeconds,
                                            startedAt: startedAt)
            }
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }

    /// Clears one workout's progress -- the "Restart" action on the Workout Day screen. Only this
    /// workout's exercises are forgotten; the same exercise stays done in any other workout that
    /// shares it.
    func reset(workoutId: String) {
        objectWillChange.send()
        localStorageService.completedExerciseIds[workoutId] = nil
        localStorageService.completedWorkoutIds.removeAll { $0 == workoutId }
        localStorageService.workoutCompletedCounts[workoutId] = nil
    }
}
