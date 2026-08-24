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
