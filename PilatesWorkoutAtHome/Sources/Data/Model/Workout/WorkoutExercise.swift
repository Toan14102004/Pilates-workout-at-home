//
//  WorkoutExercise.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import Foundation

struct WorkoutExercise: Identifiable, Equatable {
    let id: String
    let order: Int
    let name: String
    /// Still photo for list rows. The API often has no per-exercise photo and falls back to the
    /// parent workout's cover, so this can be nil and callers should substitute the workout image.
    let imageUrl: URL?
    /// Demo clip (MP4). Present for essentially every exercise the API serves.
    let videoUrl: URL?
    var durationSeconds: Int
    let restSeconds: Int
    let howTo: [String]
    let commonMistakes: [String]
    let breathingTips: [String]
    let benefits: [String]
    let otherTips: [String]

    var durationLabel: String {
        String(format: "%02d:%02d", durationSeconds / 60, durationSeconds % 60)
    }

    var hasInstructions: Bool {
        !howTo.isEmpty || !commonMistakes.isEmpty || !breathingTips.isEmpty
            || !benefits.isEmpty || !otherTips.isEmpty
    }

    static func == (lhs: WorkoutExercise, rhs: WorkoutExercise) -> Bool {
        lhs.id == rhs.id && lhs.durationSeconds == rhs.durationSeconds
    }
}

extension WorkoutExercise {
    /// Merges the instruction/media detail from `/exercises/{id}` onto a row that came from the
    /// workout list, keeping the list's duration (the server scopes duration per workout, and the
    /// standalone exercise record does not know it).
    func merging(detail: WorkoutExercise) -> WorkoutExercise {
        WorkoutExercise(
            id: id,
            order: order,
            name: detail.name.isEmpty ? name : detail.name,
            imageUrl: detail.imageUrl ?? imageUrl,
            videoUrl: videoUrl ?? detail.videoUrl,
            durationSeconds: durationSeconds,
            restSeconds: restSeconds,
            howTo: detail.howTo,
            commonMistakes: detail.commonMistakes,
            breathingTips: detail.breathingTips,
            benefits: detail.benefits,
            otherTips: detail.otherTips
        )
    }
}
