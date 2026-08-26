//
//  ProgressService.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//
//  Reads and writes the Progress tab's data. Every call needs a registered deviceId --
//  see DeviceRegistrationService -- which the tab's view models register before their first load.
//

import Combine
import Foundation

final class ProgressService {
    @Injected var networkService: NetworkService
    @Injected var deviceRegistration: DeviceRegistrationService

    private var deviceId: String { deviceRegistration.deviceId }

    func registerDeviceIfNeeded() -> AnyPublisher<Void, NetworkError> {
        deviceRegistration.registerIfNeeded()
    }

    // MARK: - Daily totals

    /// One bar of the weekly chart, or the ring for a single selected day -- built by grouping
    /// `/activities?from=&to=` client-side rather than trusting `/activities/summary`. See the
    /// header comment on ProgressAPIModels.swift for why.
    func dailyTotals(from: Date, to: Date) -> AnyPublisher<[ProgressDay], NetworkError> {
        activities(from: from, to: to)
            .map { items in
                let byDay = Dictionary(grouping: items) { Self.dayFormatter.string(from: $0.date) }
                return Self.eachDay(from: from, to: to).map { day in
                    let key = Self.dayFormatter.string(from: day)
                    let dayItems = byDay[key] ?? []
                    return ProgressDay(date: day,
                                       calories: dayItems.reduce(0) { $0 + $1.calories },
                                       durationMinutes: dayItems.reduce(0) { $0 + $1.durationMinutes })
                }
            }
            .eraseToAnyPublisher()
    }

    /// Consecutive active days ending on `date`, computed over whatever window the caller already
    /// fetched -- a real count from real entries, capped at the window length rather than however
    /// far back the streak might actually go. Standing in for `streakDays`, which the broken
    /// summary endpoint always reports as zero.
    func streakDays(endingOn date: Date, in days: [ProgressDay]) -> Int {
        let active = Set(days.filter { $0.calories > 0 || $0.durationMinutes > 0 }.map { Self.dayFormatter.string(from: $0.date) })
        var streak = 0
        var cursor = date
        while active.contains(Self.dayFormatter.string(from: cursor)) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    // MARK: - Activities

    func activities(on date: Date) -> AnyPublisher<[ProgressActivity], NetworkError> {
        activities(from: date, to: date)
    }

    private func activities(from: Date, to: Date) -> AnyPublisher<[ProgressActivity], NetworkError> {
        // Verified live: `to` is an *exclusive* upper bound at 00:00 UTC of that date -- passing
        // today's own date as `to` excludes everything logged today. `from=X&to=X` reliably comes
        // back empty even when `date=X` (used elsewhere for a single day) finds the same rows.
        // Push `to` one day later so the caller's "through this day inclusive" range is honoured.
        let exclusiveTo = Calendar.current.date(byAdding: .day, value: 1, to: to) ?? to

        return networkService
            .get(endpoint: "/activities",
                 parameters: ["deviceId": deviceId,
                             "from": Self.dayFormatter.string(from: from),
                             "to": Self.dayFormatter.string(from: exclusiveTo),
                             "limit": 100],
                 responseType: APIResponse<ActivityListDTO>.self)
            .map { ($0.data.items ?? []).compactMap(Self.mapActivity) }
            .eraseToAnyPublisher()
    }

    func createActivity(category: ProgressCategory,
                        activityAt: Date,
                        durationSeconds: Int,
                        calories: Double) -> AnyPublisher<Void, NetworkError>
    {
        let body = CreateActivityRequest(
            deviceId: deviceId,
            categoryId: category.id,
            activityAt: Self.isoFormatter.string(from: activityAt),
            timezoneOffsetMinutes: Self.timezoneOffsetMinutes,
            durationSeconds: durationSeconds,
            caloriesMode: "custom",
            calories: calories
        )
        return networkService
            .post(endpoint: "/activities", body: body, responseType: APIResponse<ActivityDTO>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func updateActivity(id: String, durationSeconds: Int, calories: Double) -> AnyPublisher<Void, NetworkError> {
        let body = UpdateActivityRequest(deviceId: deviceId, durationSeconds: durationSeconds, caloriesMode: "custom", calories: calories)
        return networkService
            .patch(endpoint: "/activities/\(id)", body: body, responseType: APIResponse<ActivityDTO>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func deleteActivity(id: String) -> AnyPublisher<Void, NetworkError> {
        // `NetworkService.delete(parameters:)` encodes `parameters` as a JSON body on any
        // non-GET method, but this endpoint reads `deviceId` from the query string only -- a
        // body-only deviceId gets "deviceId must be a string" back. Put it on the URL instead.
        let encodedDeviceId = deviceId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? deviceId
        return networkService
            .delete(endpoint: "/activities/\(id)?deviceId=\(encodedDeviceId)", responseType: APIResponse<EmptyDTO>.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    // MARK: - Categories

    func categories() -> AnyPublisher<[ProgressCategory], NetworkError> {
        networkService
            .get(endpoint: "/activity-categories", parameters: nil, responseType: APIResponse<[ActivityCategoryDTO]>.self)
            .map { dto in
                dto.data
                    .map(Self.mapCategory)
                    .sorted { lhs, rhs in
                        if lhs.popular != rhs.popular { return lhs.popular && !rhs.popular }
                        return lhs.name < rhs.name
                    }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Participated workouts

    /// The Progress tab's "Exercises" card -- what `WorkoutProgressStore.markWorkoutCompleted`
    /// pushes to the server ends up here.
    func participatedWorkouts(on date: Date) -> AnyPublisher<[ParticipatedWorkout], NetworkError> {
        networkService
            .get(endpoint: "/users/\(deviceId)/workouts/participated", parameters: nil, responseType: APIResponse<ParticipatedWorkoutListDTO>.self)
            .map { dto in
                let day = Self.dayFormatter.string(from: date)
                return (dto.data.items ?? [])
                    .filter { Self.activityDate(for: $0) == day }
                    .map(Self.mapParticipated)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Dates

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    private static let isoFormatter = ISO8601DateFormatter()

    private static var timezoneOffsetMinutes: Int { TimeZone.current.secondsFromGMT() / 60 }

    private static func eachDay(from: Date, to: Date) -> [Date] {
        var days: [Date] = []
        var cursor = Calendar.current.startOfDay(for: from)
        let end = Calendar.current.startOfDay(for: to)
        while cursor <= end {
            days.append(cursor)
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return days
    }

    /// Which day a participated row belongs to -- a finished workout's own activity date if it
    /// has one, else the day its progress started.
    private static func activityDate(for dto: ParticipatedWorkoutDTO) -> String? {
        if let completed = dto.completion?.activityDate { return completed }
        guard let startedAt = dto.progress?.startedAt, let date = isoFormatter.date(from: startedAt) else { return nil }
        return dayFormatter.string(from: date)
    }

    // MARK: - DTO -> domain

    private static func mapActivity(_ dto: ActivityDTO) -> ProgressActivity? {
        guard let dateString = dto.activityDate, let date = dayFormatter.date(from: dateString) else { return nil }
        return ProgressActivity(
            id: dto.id,
            categoryId: dto.category?.id ?? "",
            name: dto.title ?? dto.category?.name ?? "",
            iconKey: dto.category?.iconKey,
            date: date,
            durationSeconds: dto.durationSeconds ?? 0,
            calories: dto.calories ?? 0,
            met: dto.category?.met ?? 4
        )
    }

    private static func mapCategory(_ dto: ActivityCategoryDTO) -> ProgressCategory {
        ProgressCategory(id: dto.id, name: dto.name, iconKey: dto.iconKey, met: dto.met ?? 4, popular: dto.popular ?? false)
    }

    private static func mapParticipated(_ dto: ParticipatedWorkoutDTO) -> ParticipatedWorkout {
        let isCompleted = dto.status == "completed"
        let date = (dto.completion?.startedAt ?? dto.progress?.startedAt).flatMap(isoFormatter.date)

        return ParticipatedWorkout(
            id: dto.workoutId,
            name: dto.name,
            imageUrl: dto.imageUrl.flatMap(URL.init),
            level: dto.level.map { $0.prefix(1).uppercased() + $0.dropFirst() } ?? "",
            dayNumber: dto.dayNumber,
            isCompleted: isCompleted,
            progressFraction: isCompleted ? 1 : (dto.progress?.progressPercent ?? 0) / 100,
            durationSeconds: dto.completion?.durationSeconds ?? 0,
            calories: dto.completion?.calories ?? 0,
            date: date
        )
    }
}
