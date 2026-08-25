//
//  WorkoutService.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//
//  Reads the Pilates Workout API and hands the Practice flow domain models. Only the public
//  endpoints are used here -- `/users/*` and `/activities/*` need an API key the app does not
//  carry yet, which is why suggestions and progress sync are not wired.
//

import Combine
import Foundation

final class WorkoutService {
    @Injected var networkService: NetworkService
    @Injected var localStorageService: LocalStorageService

    // MARK: - Programs

    /// The multi-day programs behind the "Your Plan" carousel. Summary rows only -- they carry no
    /// day schedule, so `phases` is empty until `program(id:)` is called.
    func programs(limit: Int = 10) -> AnyPublisher<[WorkoutPlan], NetworkError> {
        networkService
            .get(endpoint: "/workout-programs",
                 parameters: ["limit": limit],
                 responseType: APIResponse<APIItems<ProgramSummaryDTO>>.self)
            .map { $0.data.items.map(Self.mapPlanSummary) }
            .eraseToAnyPublisher()
    }

    /// One program with its ordered day schedule -- drives the 30-Day Schedule screen.
    func program(id: String) -> AnyPublisher<WorkoutPlan, NetworkError> {
        networkService
            .get(endpoint: "/workout-programs/\(id)",
                 parameters: nil,
                 responseType: APIResponse<ProgramDetailDTO>.self)
            .map { Self.mapPlanDetail($0.data) }
            .eraseToAnyPublisher()
    }

    // MARK: - Workouts

    /// One workout (a program day, or a standalone Discover workout) with its exercise list,
    /// each exercise already carrying its demo video URL.
    func workout(id: String) -> AnyPublisher<WorkoutDay, NetworkError> {
        let overrides = localStorageService.exerciseDurationOverrides

        return networkService
            .get(endpoint: "/workouts/\(id)",
                 parameters: nil,
                 responseType: APIResponse<WorkoutDetailDTO>.self)
            .map { Self.mapWorkoutDay($0.data, overrides: overrides) }
            .eraseToAnyPublisher()
    }

    /// Grouped Discover sections plus the weekly ranking, behind the "Challenge" carousel.
    func discover(sectionLimit: Int = 10, weeklyLimit: Int = 10) -> AnyPublisher<DiscoverContent, NetworkError> {
        networkService
            .get(endpoint: "/workouts/discover",
                 parameters: ["sectionLimit": sectionLimit, "weeklyLimit": weeklyLimit],
                 responseType: APIResponse<DiscoverDTO>.self)
            .map { Self.discoverContent(from: $0.data) }
            .eraseToAnyPublisher()
    }

    /// Every workout in one Discover section, paged -- the "View all" screen behind a section
    /// header. The response names the section, so the screen can title itself from one call.
    func discoverSection(id: Int, page: Int = 1, limit: Int = 20) -> AnyPublisher<DiscoverSectionPage, NetworkError> {
        networkService
            .get(endpoint: "/workouts/discover/sections/\(id)",
                 parameters: ["page": page, "limit": limit],
                 responseType: APIResponse<DiscoverSectionPageDTO>.self)
            .map { Self.sectionPage(from: $0.data) }
            .eraseToAnyPublisher()
    }

    /// The full weekly ranking, paged. Discover shows the first few rows and links here.
    func weeklyTop(page: Int = 1, limit: Int = 20) -> AnyPublisher<WorkoutPage, NetworkError> {
        networkService
            .get(endpoint: "/workouts/weekly-top",
                 parameters: ["page": page, "limit": limit],
                 responseType: APIResponse<WeeklyTopPageDTO>.self)
            .map { dto in
                WorkoutPage(items: (dto.data.items ?? []).map(Self.mapDiscoverDay),
                            page: dto.data.page ?? page,
                            totalPages: dto.data.totalPages ?? 1)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Exercises

    /// Full instructions and media for one exercise. `workoutId` lets the server scope the
    /// duration to the workout the user opened it from.
    func exercise(id: String, workoutId: String? = nil) -> AnyPublisher<WorkoutExercise, NetworkError> {
        let parameters: [String: Any]? = workoutId.map { ["workoutId": $0] }

        return networkService
            .get(endpoint: "/exercises/\(id)",
                 parameters: parameters,
                 responseType: APIResponse<ExerciseDetailDTO>.self)
            .map { Self.mapExerciseDetail($0.data) }
            .eraseToAnyPublisher()
    }
}

// MARK: - DTO -> domain

private extension WorkoutService {
    static func url(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    static func mapPlanSummary(_ dto: ProgramSummaryDTO) -> WorkoutPlan {
        WorkoutPlan(
            id: dto.programId,
            title: dto.name,
            subtitle: dto.description ?? "",
            level: readable(level: dto.level),
            coverImageUrl: url(dto.coverImagePath),
            dayCount: dto.dayCount ?? 0,
            durationSeconds: dto.durationSeconds ?? 0,
            exerciseCount: dto.exerciseCount ?? 0,
            phases: []
        )
    }

    static func mapPlanDetail(_ dto: ProgramDetailDTO) -> WorkoutPlan {
        let days = (dto.days ?? []).map { mapProgramDay($0, planName: dto.name, fallbackImage: dto.coverImageUrl) }

        return WorkoutPlan(
            id: dto.programId,
            title: dto.name,
            subtitle: dto.description ?? "",
            level: readable(level: dto.level),
            coverImageUrl: url(dto.coverImageUrl),
            dayCount: dto.dayCount ?? days.count,
            durationSeconds: dto.durationSeconds ?? 0,
            exerciseCount: dto.exerciseCount ?? 0,
            phases: phases(for: days, declared: dto.phases, planName: dto.name)
        )
    }

    /// The API returns a flat day list; the Schedule screen renders phase sections. Days are
    /// grouped on `phaseNumber` when the program defines phases, and otherwise collapse into a
    /// single section named after the program.
    static func phases(for days: [WorkoutDay],
                       declared: [ProgramPhaseDTO]?,
                       planName: String) -> [WorkoutPhase]
    {
        let grouped = Dictionary(grouping: days) { $0.phaseNumber }
        let numbers = grouped.keys.compactMap { $0 }.sorted()

        guard !numbers.isEmpty else {
            // Programs without phases get a single unnamed group; the schedule omits the header
            // rather than repeating the plan name over the only section.
            return days.isEmpty ? [] : [WorkoutPhase(id: "all", number: nil, name: planName, days: days)]
        }

        return numbers.map { number in
            let name = declared?.first { $0.phaseNumber == number }?.name ?? ""
            return WorkoutPhase(id: "phase-\(number)",
                                number: number,
                                name: name,
                                days: grouped[number] ?? [])
        }
    }

    static func mapProgramDay(_ dto: ProgramDayDTO, planName: String, fallbackImage: String?) -> WorkoutDay {
        let workout = dto.workout

        return WorkoutDay(
            id: workout?.workoutId ?? "rest-\(dto.dayNumber)",
            dayNumber: dto.dayNumber,
            phaseNumber: dto.phaseNumber,
            planName: planName,
            title: dto.title ?? "Day \(dto.dayNumber)",
            summary: "",
            level: readable(level: workout?.level),
            isRestDay: dto.isRestDay ?? false,
            imageUrl: url(workout?.imageUrl ?? fallbackImage),
            durationSeconds: workout?.durationSeconds ?? 0,
            exerciseCount: workout?.exerciseCount ?? 0,
            kcal: workout?.calories,
            rank: nil,
            exercises: []
        )
    }

    static func mapWorkoutDay(_ dto: WorkoutDetailDTO, overrides: [String: Int] = [:]) -> WorkoutDay {
        let image = url(dto.imagePath)
        let exercises = (dto.exercises ?? [])
            .sorted { $0.order < $1.order }
            .map { mapExerciseRow($0, fallbackImage: image, overrides: overrides) }

        return WorkoutDay(
            id: dto.id,
            dayNumber: dto.dayNumber ?? 0,
            phaseNumber: nil,
            planName: dto.name,
            title: dto.name,
            summary: dto.description ?? "",
            level: readable(level: dto.level),
            isRestDay: false,
            imageUrl: image,
            durationSeconds: dto.estimatedDurationSeconds ?? 0,
            exerciseCount: dto.exerciseCount ?? exercises.count,
            kcal: dto.calories,
            rank: nil,
            exercises: exercises
        )
    }

    static func mapDiscoverDay(_ dto: DiscoverItemDTO) -> WorkoutDay {
        WorkoutDay(
            id: dto.workoutId,
            dayNumber: 0,
            phaseNumber: nil,
            planName: dto.name,
            title: dto.name,
            summary: dto.description ?? "",
            level: readable(level: dto.level),
            isRestDay: false,
            imageUrl: url(dto.imageUrl),
            durationSeconds: dto.durationSeconds ?? 0,
            exerciseCount: dto.exerciseCount ?? 0,
            kcal: dto.calories,
            rank: dto.rank,
            exercises: []
        )
    }

    static func mapExerciseRow(_ dto: WorkoutExerciseItemDTO,
                               fallbackImage: URL?,
                               overrides: [String: Int]) -> WorkoutExercise
    {
        let id = dto.exercise?.id ?? "order-\(dto.order)"

        return WorkoutExercise(
            id: id,
            order: dto.order,
            name: dto.nameSnapshot ?? dto.exercise?.name ?? "",
            imageUrl: fallbackImage,
            videoUrl: url(dto.videoUrlSnapshot ?? dto.exercise?.playableVideoUrl),
            // A saved edit wins over the server's figure, so the Day list, the detail screen and
            // the net-duration total all agree on what the user chose.
            durationSeconds: overrides[id] ?? dto.duration ?? 0,
            restSeconds: dto.restSeconds ?? 0,
            howTo: [],
            commonMistakes: [],
            breathingTips: [],
            benefits: [],
            otherTips: []
        )
    }

    static func mapExerciseDetail(_ dto: ExerciseDetailDTO) -> WorkoutExercise {
        let instructions = dto.instructions

        // The server sometimes leaves `howTo` empty and puts the same prose in `introduction`.
        var howTo = instructions?.howTo ?? []
        if howTo.isEmpty, let introduction = dto.introduction, !introduction.isEmpty {
            howTo = introduction
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return WorkoutExercise(
            id: dto.exerciseId,
            order: 0,
            name: dto.name,
            imageUrl: url(dto.media?.imageUrl ?? dto.media?.thumbnailUrl),
            videoUrl: url(dto.media?.videoUrl),
            durationSeconds: 0,
            restSeconds: 0,
            howTo: howTo,
            commonMistakes: instructions?.commonMistakes ?? [],
            breathingTips: instructions?.breathingTips ?? [],
            benefits: instructions?.benefits ?? [],
            otherTips: instructions?.otherTips ?? []
        )
    }

    static func discoverContent(from dto: DiscoverDTO) -> DiscoverContent {
        DiscoverContent(
            sections: (dto.sections ?? []).map { section in
                DiscoverSection(id: section.sectionId,
                                title: section.title,
                                items: (section.items ?? []).map(mapDiscoverDay))
            },
            weeklyTop: (dto.weeklyTop ?? []).map(mapDiscoverDay)
        )
    }

    static func sectionPage(from dto: DiscoverSectionPageDTO) -> DiscoverSectionPage {
        DiscoverSectionPage(
            title: dto.section?.title ?? "",
            page: WorkoutPage(items: (dto.items ?? []).map(mapDiscoverDay),
                              page: dto.page ?? 1,
                              totalPages: dto.totalPages ?? 1)
        )
    }

    /// `beginner` / `all_levels` -> `Beginner` / `All Levels`.
    static func readable(level: String?) -> String {
        guard let level, !level.isEmpty else { return "" }
        return level
            .components(separatedBy: CharacterSet(charactersIn: "_-"))
            .map(\.capitalized)
            .joined(separator: " ")
    }
}

// MARK: - Discover domain

struct DiscoverContent {
    let sections: [DiscoverSection]
    let weeklyTop: [WorkoutDay]

    static let empty = DiscoverContent(sections: [], weeklyTop: [])
}

struct DiscoverSection: Identifiable {
    let id: Int
    let title: String
    let items: [WorkoutDay]
}

/// One page of a paged workout list, shared by the category and weekly-top screens.
struct WorkoutPage {
    let items: [WorkoutDay]
    let page: Int
    let totalPages: Int
}

/// One page of a section's listing, plus the server's own name for the section.
struct DiscoverSectionPage {
    let title: String
    let page: WorkoutPage
}
