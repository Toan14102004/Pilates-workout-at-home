//
//  WorkoutTrack.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutTrack: Identifiable, Equatable {
    let id: String
    let title: String
    let durationSeconds: Int

    var durationLabel: String {
        String(format: "%02d:%02d", durationSeconds / 60, durationSeconds % 60)
    }
}
