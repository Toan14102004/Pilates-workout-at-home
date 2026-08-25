//
//  WeeklyTopView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// The full weekly ranking behind Discover's "Weekly Top" preview.
struct WeeklyTopView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: "Weekly Top", back: viewModel.back)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: Layout.Spacing.m) {
                    if viewModel.paging.isEmpty {
                        emptyState
                    } else {
                        ForEach(Array(viewModel.paging.items.enumerated()), id: \.element.id) { index, workout in
                            // `rank` is the server's position in the ranking window; the row index
                            // only stands in if a response ever omits it.
                            RankedWorkoutRow(rank: workout.rank ?? index + 1, workout: workout) {
                                viewModel.openWorkout(workout)
                            }
                            .onAppear { viewModel.loadMoreIfNeeded(reaching: workout) }
                        }

                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.m)
            }

            // Pinned rather than threaded through the rows: one ad the whole screen shares, held
            // out of the ranking so scrolling never breaks the numbering.
            PreloadedNativeAdsView(adKey: .discoverCompact,
                                   style: .contentCard,
                                   height: NativeAdViewStyle.contentCard.height)
                .padding(.horizontal, Layout.Spacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("discoverWeeklyTopVC")
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, Layout.Spacing.xxl)
        } else if let errorMessage = viewModel.errorMessage {
            WorkoutErrorView(message: errorMessage, retry: viewModel.load)
        }
    }
}
