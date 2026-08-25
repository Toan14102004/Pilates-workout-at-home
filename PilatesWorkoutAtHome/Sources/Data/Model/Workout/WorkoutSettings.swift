//
//  WorkoutSettings.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutSettings: Codable, Equatable {
    var selectedTrackId: String = WorkoutTrack.samples[0].id
    var musicVolume: Double = 0.8
    var restTimerEnabled: Bool = false
    var restTimerSeconds: Int = 10
    var preWorkoutCountdownSeconds: Int = 10
}

extension WorkoutTrack {
    static let samples: [WorkoutTrack] = [
        WorkoutTrack(id: "forbiddenNights", title: "Forbidden Nights", durationSeconds: 149),
        WorkoutTrack(id: "midnightWhispers", title: "Midnight Whispers", durationSeconds: 195),
        WorkoutTrack(id: "echoesOfSilence", title: "Echoes of Silence", durationSeconds: 242),
        WorkoutTrack(id: "neonDreams", title: "Neon Dreams", durationSeconds: 318),
        WorkoutTrack(id: "shadowDance", title: "Shadow Dance", durationSeconds: 167),
    ]
}
