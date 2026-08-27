//
//  UserProfile.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation

/// The editable identity shown on the Profile tab — everything the quiz does not already own.
/// Height / weight / target weight stay in `ProfileSetupAnswers` so the two flows never disagree.
struct UserProfile: Codable, Equatable {
    var displayName: String = "Annie"
    /// JPEG data for the avatar the user picked. `nil` falls back to the placeholder illustration.
    var avatarImageData: Data?
    /// Consecutive-day streak shown in the pill next to the "Profile" title.
    var streakCount: Int = 0
}
