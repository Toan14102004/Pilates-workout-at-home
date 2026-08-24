//
//  WorkoutPhase.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutPhase: Identifiable {
    let id: String
    let title: String
    var days: [WorkoutDay]
}
