//
//  DiscoverWorkoutViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension DiscoverWorkoutView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService
        @Injected var progressStore: WorkoutProgressStore
        @Injected var unlockStore: WorkoutUnlockStore
        @Injected var adsManager: AdsManager

        @Published var coordinator = Coordinator()
        @Published var day: WorkoutDay?
        @Published var isLoading = false
        @Published var errorMessage: String?
        @Published var showSettings = false
        @Published var showUnlockDialog = false
        @Published var isDescriptionExpanded = false

        /// How many lines of the blurb are shown before "see more".
        let collapsedDescriptionLines = 3

        private let workoutId: String
        private var cancellables = Set<AnyCancellable>()

        init(workoutId: String) {
            self.workoutId = workoutId

            // Progress and unlock state are both written from outside this screen -- by the session
            // player and by the rewarded ad -- so the screen redraws on their changes as well as
            // its own.
            for store in [progressStore.objectWillChange, unlockStore.objectWillChange] {
                store
                    .sink { [weak self] _ in self?.objectWillChange.send() }
                    .store(in: &cancellables)
            }
        }

        // MARK: - Loading

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

        // MARK: - Lock state

        var isUnlocked: Bool { unlockStore.isUnlocked(workoutId) }

        var exercises: [WorkoutExercise] { day?.exercises ?? [] }

        /// How many locked placeholder rows to draw. The exercise list itself is loaded either way
        /// -- the screen still needs the count, the duration and the cover photo from it.
        var lockedRowCount: Int { day?.displayExerciseCount ?? 0 }

        func isCompleted(_ exercise: WorkoutExercise) -> Bool {
            progressStore.isExerciseCompleted(exercise.id, in: workoutId)
        }

        var hasStarted: Bool { exercises.contains { isCompleted($0) } }

        var footerTitle: String {
            if !isUnlocked { return "Unlock Now" }
            return hasStarted ? "Continue" : "Start Now"
        }

        // MARK: - Unlocking

        /// Every route into the exercise list runs through here: tapping a locked row, or the
        /// footer button while the workout is still locked.
        func requestUnlock() {
            guard !isUnlocked else { return }
            showUnlockDialog = true
        }

        func dismissUnlockDialog() {
            showUnlockDialog = false
        }

        @MainActor
        func unlockWithAds() {
            showUnlockDialog = false

            adsManager.showRewardedAd(
                adPlacement: localStorageService.discoverUnlockRewardedAd,
                adPlacementHigh: nil
            ) { [weak self] _ in
                guard let self else { return }
                // The reward callback also fires when no ad could be served (ads switched off, no
                // fill, load failure). Unlocking anyway matches how the rest of the app treats a
                // reward it cannot deliver, and keeps a failing ad network from walling off the
                // content the user asked for.
                DispatchQueue.main.async {
                    self.unlockStore.unlock(self.workoutId)
                }
            }
        }

        func openPremium() {
            showUnlockDialog = false
            navigator.presentCover(
                RootView.Coordinator.FullScreen.subscription(subscriptionEntryPoint: .discover),
                withNavigation: true
            )
        }

        // MARK: - Navigation

        func openExercise(_ exercise: WorkoutExercise) {
            guard isUnlocked else {
                requestUnlock()
                return
            }
            localStorageService.currentWorkoutDayId = workoutId
            navigator.push(ContentView.Coordinator.Navigation.exerciseDetail(
                workoutId: workoutId,
                exerciseId: exercise.id
            ))
        }

        func startOrUnlock() {
            guard isUnlocked else {
                requestUnlock()
                return
            }
            guard !exercises.isEmpty else { return }
            localStorageService.currentWorkoutDayId = workoutId
            navigator.push(ContentView.Coordinator.Navigation.workoutSession(workoutId: workoutId))
        }

        func toggleDescription() {
            isDescriptionExpanded.toggle()
        }

        func openSettings() {
            showSettings = true
        }

        func back() {
            navigator.goBack()
        }
    }
}
