//
//  DiscoverSectionView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// Every workout in one Discover section, reached from a carousel's "View all".
struct DiscoverSectionView: View {
    @StateObject private var viewModel: ViewModel

    init(sectionId: Int, title: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(sectionId: sectionId, title: title))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                LazyVStack(spacing: Layout.Spacing.m) {
                    if viewModel.workouts.isEmpty {
                        if viewModel.isLoading {
                            ProgressView().padding(.top, Layout.Spacing.xxl)
                        } else if let errorMessage = viewModel.errorMessage {
                            WorkoutErrorView(message: errorMessage, retry: viewModel.reload)
                        }
                    }

                    ForEach(viewModel.workouts) { workout in
                        ChallengeListCard(
                            imageUrl: workout.imageUrl,
                            title: workout.title,
                            subtitle: workout.exerciseCountLabel,
                            buttonTitle: "Join now",
                            action: { viewModel.openWorkout(workout) }
                        )
                        .onAppear { viewModel.loadMoreIfNeeded(currentItem: workout) }
                    }

                    // Paging spinner, shown only while more pages are on the way.
                    if viewModel.isLoading, !viewModel.workouts.isEmpty {
                        ProgressView().padding(.vertical, Layout.Spacing.m)
                    }

                    PreloadedNativeAdsView(adKey: .practiceCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)
                }
                .padding(Layout.Spacing.m)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("discoverSectionVC")
    }

    private var header: some View {
        HStack(spacing: Layout.Spacing.s) {
            Button(action: viewModel.back) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Asset.Color.textPrimary.color)
            }

            Text(viewModel.title)
                .font(Typography.subtitleLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)

            Spacer()
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.vertical, Layout.Spacing.s)
    }
}
