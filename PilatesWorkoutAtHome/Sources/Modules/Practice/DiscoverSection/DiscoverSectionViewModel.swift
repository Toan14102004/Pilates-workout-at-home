//
//  DiscoverSectionViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension DiscoverSectionView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var workouts: [WorkoutDay] = []
        @Published var isLoading = false
        @Published var errorMessage: String?

        let title: String
        private let sectionId: Int
        private var page = 0
        private var totalPages = 1
        private var cancellables = Set<AnyCancellable>()

        init(sectionId: Int, title: String) {
            self.sectionId = sectionId
            self.title = title
        }

        var hasMore: Bool { page < totalPages }

        func loadIfNeeded() {
            guard workouts.isEmpty, !isLoading else { return }
            loadNextPage()
        }

        /// Retry entry point for the error state -- starts the list over from the first page.
        func reload() {
            page = 0
            totalPages = 1
            workouts = []
            loadNextPage()
        }

        func loadNextPage() {
            guard !isLoading, hasMore else { return }
            isLoading = true
            errorMessage = nil

            workoutService.discoverSection(id: sectionId, page: page + 1)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] result in
                    guard let self else { return }
                    page = result.page
                    totalPages = result.totalPages
                    workouts.append(contentsOf: result.items)
                }
                .store(in: &cancellables)
        }

        /// Pulls the next page in once the last row is on screen.
        func loadMoreIfNeeded(currentItem: WorkoutDay) {
            guard currentItem.id == workouts.last?.id else { return }
            loadNextPage()
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.workoutDay(workoutId: workout.id))
        }

        func back() {
            navigator.goBack()
        }
    }
}
