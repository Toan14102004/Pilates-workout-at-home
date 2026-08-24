//
//  WorkoutDayViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

extension WorkoutDayView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var showSettings = false
        @Published var day: WorkoutDay?
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let workoutId: String
        private var cancellables = Set<AnyCancellable>()

        init(workoutId: String) {
            self.workoutId = workoutId
        }

        func loadIfNeeded() {
            guard day == nil, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            workoutService.workout(id: workoutId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] day in
                    self?.day = day
                }
                .store(in: &cancellables)
        }

        var exercises: [WorkoutExercise] { day?.exercises ?? [] }

        var completedExerciseIds: Set<String> { Set(localStorageService.completedExerciseIds) }

        func isCompleted(_ exercise: WorkoutExercise) -> Bool { completedExerciseIds.contains(exercise.id) }

        var hasStarted: Bool { exercises.contains { isCompleted($0) } }

        var firstPendingExercise: WorkoutExercise? {
            exercises.first { !isCompleted($0) } ?? exercises.first
        }

        func openExercise(_ exercise: WorkoutExercise) {
            localStorageService.currentWorkoutDayId = workoutId
            navigator.push(ContentView.Coordinator.Navigation.exerciseDetail(
                workoutId: workoutId,
                exerciseId: exercise.id
            ))
        }

        // TODO: this should launch the Flow Practice session player once it's built; for now it
        // opens the first pending exercise's detail view as a reasonable stand-in entry point.
        func startOrContinue() {
            guard let exercise = firstPendingExercise else { return }
            openExercise(exercise)
        }

        func restart() {
            let ids = Set(exercises.map(\.id))
            localStorageService.completedExerciseIds.removeAll { ids.contains($0) }
            localStorageService.completedWorkoutIds.removeAll { $0 == workoutId }
        }

        func openSettings() {
            showSettings = true
        }

        func back() {
            navigator.goBack()
        }
    }
}
