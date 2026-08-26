//
//  WorkoutSettingsSheetViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

enum WorkoutSettingsPanel {
    case overview
    case songList
    case restTimer
    case countdown
}

extension WorkoutSettingsSheet {
    class ViewModel: BaseViewModel {
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var panel: WorkoutSettingsPanel = .overview
        @Published var settings: WorkoutSettings {
            didSet { localStorageService.workoutSettings = settings }
        }

        let tracks = WorkoutTrack.samples

        init() {
            settings = LocalStorageService.shared.workoutSettings
        }

        var selectedTrack: WorkoutTrack {
            tracks.first { $0.id == settings.selectedTrackId } ?? tracks[0]
        }

        func selectTrack(_ track: WorkoutTrack) {
            settings.selectedTrackId = track.id
        }

        /// The prev/next controls on the overview's music card cycle through the sample list --
        /// there is no audio engine behind them yet, so this is the track that would play next
        /// rather than a transport control.
        func previousTrack() {
            let index = tracks.firstIndex { $0.id == selectedTrack.id } ?? 0
            settings.selectedTrackId = tracks[(index - 1 + tracks.count) % tracks.count].id
        }

        func nextTrack() {
            let index = tracks.firstIndex { $0.id == selectedTrack.id } ?? 0
            settings.selectedTrackId = tracks[(index + 1) % tracks.count].id
        }

        func confirmTrack() {
            panel = .overview
        }

        func confirmRestTimer() {
            panel = .overview
        }

        func confirmCountdown() {
            panel = .overview
        }
    }
}
