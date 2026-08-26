//
//  DiscoverCategoryViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import Combine
import Foundation

extension DiscoverCategoryView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var workoutService: WorkoutService

        @Published var coordinator = Coordinator()
        @Published var paging = WorkoutListPaging()
        @Published var title: String
        @Published var isLoading = false
        @Published var errorMessage: String?

        private let sectionId: Int
        private var cancellables = Set<AnyCancellable>()

        /// `title` comes from the section header the user tapped so the screen has one before its
        /// first response lands; the response then replaces it with the server's own.
        init(sectionId: Int, title: String) {
            self.sectionId = sectionId
            self.title = title
        }

        func loadIfNeeded() {
            guard !paging.hasLoaded, !isLoading else { return }
            load()
        }

        func load() {
            paging.reset()
            fetch(page: 1)
        }

        func loadMoreIfNeeded(reaching workout: WorkoutDay) {
            guard !isLoading, paging.shouldLoadMore(reaching: workout) else { return }
            fetch(page: paging.nextPage)
        }

        private func fetch(page: Int) {
            isLoading = true
            errorMessage = nil

            workoutService.discoverSection(id: sectionId, page: page)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] result in
                    guard let self else { return }
                    if !result.title.isEmpty { title = result.title }
                    paging.apply(result.page)
                }
                .store(in: &cancellables)
        }

        func openWorkout(_ workout: WorkoutDay) {
            navigator.push(ContentView.Coordinator.Navigation.discoverWorkout(workoutId: workout.id))
        }

        func back() {
            navigator.goBack()
        }
    }
}
