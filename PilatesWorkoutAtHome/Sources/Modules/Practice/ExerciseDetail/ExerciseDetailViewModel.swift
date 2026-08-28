//
//  ExerciseDetailViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Combine
import Foundation

extension ExerciseDetailView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var localStorageService: LocalStorageService
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var exercises: [WorkoutExercise] = []
        @Published var currentIndex = 0
        @Published var isEditingDuration = false
        @Published var draftDurationSeconds = 0
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let workoutId: String
        private let initialExerciseId: String
        /// Instruction text arrives from a second call per exercise, so fetched details are kept
        /// to avoid re-requesting when the user pages back and forth.
        private var detailRequested = Set<String>()
        private var cancellables = Set<AnyCancellable>()
        private let musicPlayer = BackgroundMusicPlayer.shared

        init(workoutId: String, initialExerciseId: String) {
            self.workoutId = workoutId
            self.initialExerciseId = initialExerciseId
        }

        var exercise: WorkoutExercise? {
            guard exercises.indices.contains(currentIndex) else { return nil }
            return exercises[currentIndex]
        }

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
                    currentIndex = day.exercises.firstIndex { $0.id == self.initialExerciseId } ?? 0
                    draftDurationSeconds = exercise?.durationSeconds ?? 0
                    loadDetailForCurrent()
                    startBackgroundMusic()
                }
                .store(in: &cancellables)
        }

        /// This screen previews one exercise's demo clip (silent) rather than running a timed
        /// session, but it's still "practicing" from the user's point of view -- the chosen
        /// workout track should be audible here too, exactly like the full guided session.
        private func startBackgroundMusic() {
            let settings = localStorageService.workoutSettings
            BackgroundMusicService.shared.fetchBackgroundMusic()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] tracks in
                    guard let self, let track = tracks.first(where: { $0.id == settings.selectedTrackId }) ?? tracks.first else { return }
                    self.musicPlayer.play(track, volume: Float(settings.musicVolume), loop: true)
                })
                .store(in: &cancellables)
        }

        /// The workout list gives name, duration and video; How-to / Common Mistakes /
        /// Breathing Tips only come from `/exercises/{id}`.
        private func loadDetailForCurrent() {
            guard let exercise, !detailRequested.contains(exercise.id) else { return }
            detailRequested.insert(exercise.id)

            workoutService.exercise(id: exercise.id, workoutId: workoutId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure = completion {
                        // The list already carries name, duration and video, so a failed detail
                        // call costs the instruction text only -- not the screen.
                        self?.detailRequested.remove(exercise.id)
                    }
                } receiveValue: { [weak self] detail in
                    guard let self,
                          let index = exercises.firstIndex(where: { $0.id == detail.id }) else { return }
                    exercises[index] = exercises[index].merging(detail: detail)
                }
                .store(in: &cancellables)
        }

        var paginationLabel: String { "\(currentIndex + 1)/\(exercises.count)" }

        var canGoPrevious: Bool { currentIndex > 0 }

        var canGoNext: Bool { currentIndex < exercises.count - 1 }

        func goPrevious() {
            guard canGoPrevious else { return }
            currentIndex -= 1
            resetDraft()
            loadDetailForCurrent()
        }

        func goNext() {
            guard canGoNext else { return }
            currentIndex += 1
            resetDraft()
            loadDetailForCurrent()
        }

        func resetDraft() {
            draftDurationSeconds = exercise?.durationSeconds ?? 0
            isEditingDuration = false
        }

        /// Duration edits stay on the device -- the API has no endpoint that accepts one, so the
        /// value is stored locally and reapplied whenever the workout is loaded again.
        func save() {
            guard exercises.indices.contains(currentIndex) else { return }
            let exerciseId = exercises[currentIndex].id
            exercises[currentIndex].durationSeconds = draftDurationSeconds
            localStorageService.exerciseDurationOverrides[exerciseId] = draftDurationSeconds
            isEditingDuration = false
        }

        func close() {
            musicPlayer.stop()
            navigator.goBack()
        }

        /// Catches leaving via a back-swipe gesture, which never calls `close()`.
        func stopMusic() {
            musicPlayer.stop()
        }

        /// Keeps the music in step with the demo clip: paused when the user pauses the clip or
        /// it plays through to the end, resumed when they play or replay it.
        func handleClipPlaybackChange(isPlaying: Bool) {
            if isPlaying {
                musicPlayer.resume()
            } else {
                musicPlayer.pause()
            }
        }
    }
}
