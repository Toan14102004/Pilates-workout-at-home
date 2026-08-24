//
//  PracticeHomeViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

extension PracticeHomeView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var plans: [WorkoutPlan] = []
        @Published var challenges: [WorkoutDay] = []
        @Published var justForYou: [WorkoutDay] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        private var cancellables = Set<AnyCancellable>()

        var hasLoaded: Bool { !plans.isEmpty || !challenges.isEmpty || !justForYou.isEmpty }

        func loadIfNeeded() {
            guard !hasLoaded, !isLoading else { return }
            load()
        }

        func load() {
            isLoading = true
            errorMessage = nil

            // `/workouts/suggestions` would be the right source for "Just for you", but it 404s
            // ("User not found") until the device is registered through the secured `POST /users`.
            // Until the app carries an API key, Discover stands in: its weekly ranking feeds
            // "Just for you" and its first section feeds "Challenge".
            Publishers.Zip(
                workoutService.programs(limit: 10),
                workoutService.discover(sectionLimit: 6, weeklyLimit: 10)
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                isLoading = false
                if case let .failure(error) = completion {
                    errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] programs, discover in
                guard let self else { return }
                plans = programs
                challenges = discover.sections.first?.items ?? []
                justForYou = discover.weeklyTop
                enrichVisiblePlans()
            }
            .store(in: &cancellables)
        }

        /// `/workout-programs` returns no duration or exercise count, but the card is designed to
        /// show "11 Min  12 Exercises". Those come from the program's first day, so the few cards
        /// actually on screen are topped up with their detail call; the rest keep the "N Days"
        /// fallback until the list endpoint carries the fields.
        private static let enrichedPlanCount = 3

        private func enrichVisiblePlans() {
            for plan in plans.prefix(Self.enrichedPlanCount) {
                workoutService.program(id: plan.id)
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        // A failure here only costs the metrics line, so the card keeps its fallback.
                    } receiveValue: { [weak self] detail in
                        guard let self,
                              let index = plans.firstIndex(where: { $0.id == detail.id }) else { return }
                        plans[index] = detail
                    }
                    .store(in: &cancellables)
            }
        }

        var hasStartedPlan: Bool { localStorageService.currentWorkoutDayId != nil }

        var planButtonTitle: String { hasStartedPlan ? "Continue" : "Start now" }

        func buttonTitle(for plan: WorkoutPlan) -> String {
            plan.id == localStorageService.currentProgramId ? "Continue" : "Start now"
        }

        func openPlan(_ plan: WorkoutPlan) {
            navigator.push(ContentView.Coordinator.Navigation.workoutSchedule(programId: plan.id))
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: workout.id))
        }
    }
}
