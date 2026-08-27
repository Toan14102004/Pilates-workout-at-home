//
//  WorkoutSettingsViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

extension WorkoutSettingsView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var settings = ProfileWorkoutSettings() {
            didSet { localStorageService.profileWorkoutSettings = settings }
        }

        /// Which "pick a duration" sheet is open, if any.
        @Published var editingDuration: DurationField?

        enum DurationField: Identifiable {
            case restTimer
            case countdown

            var id: Int { self == .restTimer ? 0 : 1 }

            var title: String {
                self == .restTimer ? "Rest timer" : "Countdown before workout"
            }
        }

        func load() {
            settings = localStorageService.profileWorkoutSettings
        }

        func togglePlayback() {
            settings.isMusicPlaying.toggle()
        }

        func back() {
            navigation.goBack()
        }
    }
}
