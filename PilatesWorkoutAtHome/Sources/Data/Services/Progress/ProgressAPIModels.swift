//
//  ProgressAPIModels.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Wire format for /activities, /activity-categories and
//  /users/{deviceId}/workouts/participated. Verified against live responses on 2026-08-26 --
//  the shapes here are not the same as the OpenAPI examples for a couple of fields, so treat
//  this file as the source of truth over the spec if the two ever disagree.
//
//  `/activities/summary` and its alias `/users/{deviceId}/activity-summary` are deliberately not
//  modelled here: verified live, both endpoints report every total as zero for a device and date
//  range that `/activities` itself shows real entries for (created directly and via a completed
//  workout). Retried after a delay in case of an indexing lag -- same result. ProgressService
//  reconstructs day totals from `/activities?from=&to=` instead; see `dailyTotals`. Worth
//  reporting to backend, but not a client bug to work around further than that.
//

import Foundation

// MARK: - Activities

struct ActivityListDTO: Codable {
    let items: [ActivityDTO]?
}

struct ActivityDTO: Codable, Identifiable {
    let id: String
    let category: ActivityCategoryDTO?
    let title: String?
    let activityDate: String?
    let durationSeconds: Int?
    let calories: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case category, title, activityDate, durationSeconds, calories
    }
}

struct CreateActivityRequest: Codable {
    let deviceId: String
    let categoryId: String
    let activityAt: String
    let timezoneOffsetMinutes: Int
    let durationSeconds: Int
    let caloriesMode: String
    let calories: Double
}

struct UpdateActivityRequest: Codable {
    let deviceId: String
    let durationSeconds: Int?
    let caloriesMode: String?
    let calories: Double?
}

// MARK: - Categories

struct ActivityCategoryDTO: Codable, Identifiable {
    let id: String
    let name: String
    let iconKey: String?
    let met: Double?
    let popular: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, iconKey, met, popular
    }
}

// MARK: - Participated workouts

struct ParticipatedWorkoutListDTO: Codable {
    let items: [ParticipatedWorkoutDTO]?
}

struct ParticipatedWorkoutDTO: Codable {
    let workoutId: String
    let name: String
    let imageUrl: String?
    let level: String?
    let dayNumber: Int?
    let status: String?
    let progress: ParticipatedProgressDTO?
    let completion: ParticipatedCompletionDTO?
}

struct ParticipatedProgressDTO: Codable {
    let progressPercent: Double?
    let startedAt: String?
}

struct ParticipatedCompletionDTO: Codable {
    let activityDate: String?
    let startedAt: String?
    let durationSeconds: Int?
    let calories: Double?
}
