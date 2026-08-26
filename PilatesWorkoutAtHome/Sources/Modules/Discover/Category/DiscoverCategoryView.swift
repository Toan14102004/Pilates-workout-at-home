//
//  DiscoverCategoryView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// Every workout in one Discover section -- the "View all" screen behind a carousel header.
struct DiscoverCategoryView: View {
    @StateObject private var viewModel: ViewModel

    init(sectionId: Int, title: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(sectionId: sectionId, title: title))
    }

    var body: some View {
        VStack(spacing: 0) {
            DiscoverNavigationBar(title: viewModel.title, back: viewModel.back)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    if viewModel.paging.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.paging.items) { workout in
                            DiscoverListCard(workout: workout) {
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

            // Pinned rather than threaded through the cards -- see `WeeklyTopView`.
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
        .trackScreen("discoverCategoryVC")
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
