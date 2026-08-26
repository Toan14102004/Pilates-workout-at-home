//
//  DiscoverHomeView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// The Discover tab: the plan in progress, the API's grouped workout sections as carousels, and a
/// preview of the weekly ranking. Every workout it opens is locked -- see `DiscoverWorkoutView`.
struct DiscoverHomeView: View {
    // Owned, not injected, for the same reason `PracticeHomeView` owns its view model: ContentView
    // rebuilds its body on every tab/ads/language change and would replace an @ObservedObject
    // mid-load, cancelling the request and leaving the screen blank.
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if viewModel.isLoading, !viewModel.hasLoaded {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, Layout.Spacing.xxl)
                } else if let errorMessage = viewModel.errorMessage, !viewModel.hasLoaded {
                    WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                } else {
                    recentSection

                    PreloadedNativeAdsView(adKey: .discoverCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)

                    ForEach(viewModel.sections) { section in
                        sectionCarousel(section)
                    }

                    PreloadedNativeAdsView(adKey: .discoverCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)

                    weeklyTopSection
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.bottom, Layout.Spacing.xxl)
        }
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("discoverHomeVC")
    }

    // MARK: - Recent

    @ViewBuilder
    private var recentSection: some View {
        // Hidden outright until a plan is under way: the design has no empty state for it, and an
        // empty card would sit above the fold on a first run.
        if let plan = viewModel.recentPlan {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderRow(title: "Recent")

                RecentPlanCard(
                    imageUrl: viewModel.recentDay?.imageUrl ?? plan.coverImageUrl,
                    title: plan.title,
                    subtitle: viewModel.recentSubtitle,
                    progress: viewModel.recentProgress,
                    action: viewModel.openRecentPlan
                )
            }
        }
    }

    // MARK: - Sections

    private func sectionCarousel(_ section: DiscoverSection) -> some View {
        // Offered on every section, as the design has it, and not only on ones with more rows to
        // give: the category screen is the section's full-width listing, and most sections the API
        // ships today fit inside the carousel preview.
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderRow(title: section.title) { viewModel.openSection(section) }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: DiscoverWorkoutCard.cardSpacing) {
                    ForEach(section.items) { workout in
                        DiscoverWorkoutCard(workout: workout) {
                            viewModel.openWorkout(workout)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Weekly Top

    private var weeklyTopSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            SectionHeaderRow(title: "Weekly Top") { viewModel.openWeeklyTop() }

            VStack(spacing: 12) {
                ForEach(Array(viewModel.weeklyTop.enumerated()), id: \.element.id) { index, workout in
                    RankedWorkoutRow(rank: workout.rank ?? index + 1, workout: workout) {
                        viewModel.openWorkout(workout)
                    }
                }
            }
        }
    }
}

#Preview {
    DiscoverHomeView()
        .preview()
}
