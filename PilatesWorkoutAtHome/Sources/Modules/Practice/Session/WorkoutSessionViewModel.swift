//
//  WorkoutSessionViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension WorkoutSessionView {
    class ViewModel: BaseViewModel {
        /// Mirrors the Flow Practice screens in Figma: Get ready -> Exercise -> Rest -> ...,
        /// with pause opening its own screen of options rather than freezing in place.
        enum Phase: Equatable {
            case getReady
            case exercise
            case rest
            case completed
        }

        static let getReadySeconds = 10

        @Navigation var navigator
        @Injected var workoutService: WorkoutService
        @Injected var progressStore: WorkoutProgressStore

        @Published var coordinator = Coordinator()
        @Published var exercises: [WorkoutExercise] = []
        @Published var index = 0
        @Published var phase: Phase = .getReady
        @Published var remainingSeconds = 0
        /// Plain pause from the transport row: the session stays on the same screen.
        @Published var isPaused = false
        /// Raised by Back -- a confirmation before abandoning the session, not a pause control.
        @Published var showsPauseOptions = false
        @Published var isLoading = false
        @Published var errorMessage: String?
        /// Set when the user taps the info dot; drives the instructions sheet.
        @Published var showsInstructions = false
        @Published var instructionsExercise: WorkoutExercise?

        /// Time actually spent working: paused, resting and backgrounded seconds are never added,
        /// which is what `PUT /workouts/{id}/progress` asks for.
        private(set) var elapsedSeconds = 0

        private let workoutId: String
        private var timerCancellable: AnyCancellable?
        private var cancellables = Set<AnyCancellable>()

        init(workoutId: String) {
            self.workoutId = workoutId
        }

        // MARK: - Derived

        var currentExercise: WorkoutExercise? {
            exercises.indices.contains(index) ? exercises[index] : nil
        }

        var nextExercise: WorkoutExercise? {
            exercises.indices.contains(index + 1) ? exercises[index + 1] : nil
        }

        /// During rest the screen previews the exercise that is coming up.
        var displayedExercise: WorkoutExercise? {
            phase == .rest ? nextExercise : currentExercise
        }

        var progressFraction: Double {
            guard !exercises.isEmpty else { return 0 }
            return Double(index) / Double(exercises.count)
        }

        var positionLabel: String { "Exercise \(index + 1)/\(exercises.count)" }

        var nextPositionLabel: String { "Next: \(min(index + 2, exercises.count))/\(exercises.count)" }

        var timerLabel: String {
            String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        }

        var elapsedLabel: String {
            String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
        }

        /// The demo clip only runs while the exercise itself is running. During the Get ready
        /// countdown and rest intervals it holds on its first frame as a still preview, so the
        /// movement starts when the timer does rather than part-way through.
        var isClipPlaying: Bool { phase == .exercise && !isStopped }

        /// Anything that should freeze the clock: an explicit pause, or the exit confirmation.
        private var isStopped: Bool { isPaused || showsPauseOptions }

        // MARK: - Loading

        func loadIfNeeded() {
            guard exercises.isEmpty, !isLoading else { return }
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
                    guard let self else { return }
                    exercises = day.exercises
                    // Resuming picks up at the first exercise not already done.
                    index = day.exercises.firstIndex { !self.progressStore.isExerciseCompleted($0.id) } ?? 0
                    beginGetReady()
                }
                .store(in: &cancellables)
        }

        // MARK: - Phases

        private func beginGetReady() {
            guard currentExercise != nil else {
                finish()
                return
            }
            phase = .getReady
            remainingSeconds = Self.getReadySeconds
            startTimer()
        }

        private func beginExercise() {
            guard let exercise = currentExercise else {
                finish()
                return
            }
            phase = .exercise
            remainingSeconds = exercise.durationSeconds
            startTimer()
        }

        private func beginRest(after exercise: WorkoutExercise) {
            guard exercise.restSeconds > 0, nextExercise != nil else {
                advance()
                return
            }
            phase = .rest
            remainingSeconds = exercise.restSeconds
            startTimer()
        }

        private func completeCurrentExercise() {
            guard let exercise = currentExercise else { return }
            progressStore.markExerciseCompleted(exercise, in: workoutId)
            beginRest(after: exercise)
        }

        private func advance() {
            guard index + 1 < exercises.count else {
                finish()
                return
            }
            index += 1
            beginExercise()
        }

        private func finish() {
            stopTimer()
            phase = .completed
            progressStore.markWorkoutCompleted(workoutId: workoutId, elapsedSeconds: elapsedSeconds)
        }

        // MARK: - Timer

        private func startTimer() {
            stopTimer()
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in self?.tick() }
        }

        private func stopTimer() {
            timerCancellable?.cancel()
            timerCancellable = nil
        }

        private func tick() {
            guard !isStopped else { return }

            if phase == .exercise {
                elapsedSeconds += 1
            }

            guard remainingSeconds > 0 else { return }
            remainingSeconds -= 1

            guard remainingSeconds == 0 else { return }
            switch phase {
            case .getReady:
                beginExercise()
            case .exercise:
                completeCurrentExercise()
            case .rest:
                advance()
            case .completed:
                break
            }
        }

        // MARK: - Controls

        /// The transport row's middle button: stop and start the clock in place.
        func togglePause() {
            guard phase != .completed else { return }
            isPaused.toggle()
        }

        /// Back asks before throwing away a session in progress.
        func requestExit() {
            guard phase != .completed else {
                exit()
                return
            }
            showsPauseOptions = true
        }

        /// "Keep exercising" -- picks the session back up exactly where it stopped.
        func resume() {
            showsPauseOptions = false
            isPaused = false
        }

        /// "Restart this exercise" -- same exercise, clock back to the top.
        func restartCurrentExercise() {
            showsPauseOptions = false
            isPaused = false
            beginExercise()
        }

        /// "Do it later" -- leaves the session; progress up to here is already saved.
        func doItLater() {
            stopTimer()
            navigator.goBack()
        }

        /// Leaving the app pauses rather than quietly accruing time the user did not exercise.
        func handleScenePhaseChange(isActive: Bool) {
            guard !isActive, phase != .completed else { return }
            isPaused = true
        }

        /// Skips the Get ready countdown, or the rest interval.
        func skip() {
            switch phase {
            case .getReady:
                beginExercise()
            case .rest:
                advance()
            default:
                break
            }
        }

        func previousExercise() {
            guard index > 0 else { return }
            isPaused = false
            index -= 1
            beginExercise()
        }

        func nextExerciseTapped() {
            guard phase != .completed else { return }
            isPaused = false
            if phase == .rest {
                advance()
            } else {
                completeCurrentExercise()
            }
        }

        func showInstructions() {
            guard let exercise = displayedExercise else { return }
            instructionsExercise = exercise
            showsInstructions = true

            // The workout list carries no instruction text; only `/exercises/{id}` has it.
            guard !exercise.hasInstructions else { return }
            workoutService.exercise(id: exercise.id, workoutId: workoutId)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    // A failed lookup just leaves the sheet showing name and clip.
                } receiveValue: { [weak self] detail in
                    guard let self else { return }
                    if let position = exercises.firstIndex(where: { $0.id == detail.id }) {
                        exercises[position] = exercises[position].merging(detail: detail)
                        if instructionsExercise?.id == detail.id {
                            instructionsExercise = exercises[position]
                        }
                    }
                }
                .store(in: &cancellables)
        }

        func exit() {
            stopTimer()
            navigator.goBack()
        }
    }
}
