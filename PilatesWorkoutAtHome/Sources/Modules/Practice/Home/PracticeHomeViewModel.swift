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
        /// Kept so "View all" can open the section the carousel was filled from.
        @Published var challengeSection: DiscoverSection?
        @Published var justForYou: [WorkoutDay] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        private var cancellables = Set<AnyCancellable>()

        var hasLoaded: Bool { !plans.isEmpty || !challenges.isEmpty || !justForYou.isEmpty }

        func loadIfNeeded() {
            guard !hasLoaded, !isLoading else { return }
            load()
        }

        /// "Start now"/"Continue" and the card title read `localStorageService` live on every
        /// body evaluation, but that alone doesn't get this screen redrawn -- `loadIfNeeded()`
        /// is a no-op after the first load, so returning here from an exercise or a session
        /// otherwise leaves the stale title on screen until SwiftUI recomputes it for some other
        /// reason. `objectWillChange.send()` forces that recompute without refetching anything.
        func refreshOnAppear() {
            objectWillChange.send()
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
                challengeSection = discover.sections.first
                challenges = discover.sections.first?.items ?? []
                justForYou = discover.weeklyTop
            }
            .store(in: &cancellables)
        }

        var hasStartedPlan: Bool { localStorageService.currentWorkoutDayId != nil }

        var planButtonTitle: String { hasStartedPlan ? "Continue" : "Start now" }

        func buttonTitle(for plan: WorkoutPlan) -> String {
            isInProgress(plan) ? "Continue" : "Start now"
        }

        /// Once a plan is under way the card names the day being worked on rather than the plan,
        /// per the design's note on the main screen.
        func cardTitle(for plan: WorkoutPlan) -> String {
            guard isInProgress(plan),
                  let dayId = localStorageService.currentWorkoutDayId,
                  let day = plan.days.first(where: { $0.id == dayId })
            else { return plan.title }

            return "DAY \(day.dayNumber)"
        }

        private func isInProgress(_ plan: WorkoutPlan) -> Bool {
            plan.id == localStorageService.currentProgramId
        }

        func openPlan(_ plan: WorkoutPlan) {
            navigator.push(ContentView.Coordinator.Navigation.workoutSchedule(programId: plan.id))
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: workout.id))
        }

        /// Both carousels are filled from Discover, so their "View all" links land on the Discover
        /// screens that list the same thing in full.
        func openChallengeList() {
            guard let section = challengeSection else { return }
            navigator.push(ContentView.Coordinator.Navigation.discoverCategory(
                sectionId: section.id,
                title: section.title
            ))
        }

        func openJustForYouList() {
            navigator.push(ContentView.Coordinator.Navigation.discoverWeeklyTop)
        }
    }
}
