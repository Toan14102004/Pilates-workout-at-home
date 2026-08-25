//
//  PracticeHomeView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct PracticeHomeView: View {
    // Owned, not injected: ContentView rebuilds its body on every tab/ads/language change, and an
    // @ObservedObject built there would be replaced mid-flight -- cancelling the load and leaving
    // the screen empty with no spinner and no error.
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.Spacing.l) {
                if viewModel.isLoading, !viewModel.hasLoaded {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage, !viewModel.hasLoaded {
                    WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                } else {
                    yourPlanSection

                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                    challengeSection

                    justForYouSection
                }
            }
            .padding(.horizontal, Layout.Spacing.m)
            .padding(.bottom, Layout.Spacing.xxl)
        }
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("practiceHomeVC")
    }

    private var loadingState: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.top, Layout.Spacing.xxl)
    }

    // MARK: - Your Plan

    private var yourPlanSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            Text("Your Plan")
                .font(Typography.subtitleSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Layout.Spacing.s) {
                    ForEach(Array(viewModel.plans.enumerated()), id: \.element.id) { index, plan in
                        PlanHeroCard(
                            imageUrl: plan.coverImageUrl,
                            title: viewModel.cardTitle(for: plan),
                            durationText: plan.durationText,
                            exercisesText: plan.exercisesText,
                            fallbackText: plan.fallbackText,
                            buttonTitle: viewModel.buttonTitle(for: plan),
                            paletteIndex: index,
                            action: { viewModel.openPlan(plan) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Challenge

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            sectionHeader(title: "Challenge", action: viewModel.openAllChallenges)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Layout.Spacing.s) {
                    ForEach(viewModel.challenges) { workout in
                        ChallengeCard(
                            imageUrl: workout.imageUrl,
                            title: workout.title,
                            subtitle: workout.exerciseCountLabel,
                            buttonTitle: "Join now",
                            action: { viewModel.openWorkout(workout) }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Just for you

    private var justForYouSection: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            sectionHeader(title: "Just for you")

            VStack(spacing: Layout.Spacing.m) {
                ForEach(viewModel.justForYou) { workout in
                    WorkoutExerciseRow(
                        imageUrl: workout.imageUrl,
                        title: workout.title,
                        subtitle: workout.exerciseCountLabel,
                        action: { viewModel.openWorkout(workout) }
                    )
                }
            }
        }
    }

    private func sectionHeader(title: String, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.custom("Didot-Bold", size: 18))
                .foregroundStyle(Asset.Color.textPrimary.color)
            Spacer()
            if let action {
                Button("View all", action: action)
                    .font(Typography.labelMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .underline()
            }
        }
    }
}
