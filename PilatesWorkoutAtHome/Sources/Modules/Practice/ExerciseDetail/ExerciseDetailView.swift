//
//  ExerciseDetailView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct ExerciseDetailView: View {
    @StateObject private var viewModel: ViewModel

    init(workoutId: String, initialExerciseId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(
            workoutId: workoutId,
            initialExerciseId: initialExerciseId
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                hero
                    .frame(width: UIScreen.main.bounds.width,
                           height: Layout.heroHeight + UIApplication.shared.safeAreaTop)
                    .clipped()

                HeroOverlayButton(image: Asset.Icon.Commo.xmark, action: viewModel.close)
                    .padding(Layout.Spacing.m)
                    .padding(.top, UIApplication.shared.safeAreaTop)
            }
            .clipped()
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                    if viewModel.isLoading, viewModel.exercise == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, Layout.Spacing.xxl)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.exercise == nil {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else if let exercise = viewModel.exercise {
                        content(exercise)
                    }
                }
                .padding(Layout.Spacing.m)
            }
            .onChange(of: viewModel.draftDurationSeconds) { _ in
                if viewModel.draftDurationSeconds != viewModel.exercise?.durationSeconds {
                    viewModel.isEditingDuration = true
                }
            }

            if viewModel.exercise != nil {
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("exerciseDetailVC")
    }

    /// The API ships a short demo clip for essentially every exercise; the still image is only a
    /// fallback for the few that have none.
    @ViewBuilder
    private var hero: some View {
        if let videoUrl = viewModel.exercise?.videoUrl {
            ExerciseVideoPlayer(url: videoUrl)
                .id(videoUrl)
        } else {
            RemoteImageView(url: viewModel.exercise?.imageUrl)
        }
    }

    @ViewBuilder
    private func content(_ exercise: WorkoutExercise) -> some View {
        Text(exercise.name)
            .font(.custom("Didot-Bold", size: 24))
            .foregroundStyle(Asset.Color.textPrimary.color)

        DurationStepper(seconds: $viewModel.draftDurationSeconds)

        bulletSection(title: "How to Do", items: exercise.howTo)
        bulletSection(title: "Common Mistakes", items: exercise.commonMistakes)
        bulletSection(title: "Breathing Tips", items: exercise.breathingTips)
        bulletSection(title: "Benefits", items: exercise.benefits)
        bulletSection(title: "Other Tips", items: exercise.otherTips)
    }

    @ViewBuilder
    private func bulletSection(title: String, items: [String]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
                Text(title)
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .top, spacing: Layout.Spacing.xs) {
                            Text("•")
                            Text(item)
                        }
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                    }
                }
            }
        }
    }

    private var footer: some View {
        Group {
            if viewModel.isEditingDuration {
                HStack(spacing: Layout.Spacing.s) {
                    Button("Reset", action: viewModel.resetDraft)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.mainColor.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.Spacing.m)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Asset.Color.mainColor.color, lineWidth: 1.5))

                    Button("Save", action: viewModel.save)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.white.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.Spacing.m)
                        .background(Asset.Color.mainColor.color)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                HStack {
                    Button(action: viewModel.goPrevious) {
                        Text("‹").font(.system(size: 20, weight: .semibold))
                            .frame(width: 32, height: 32)
                    }
                    .disabled(!viewModel.canGoPrevious)
                    .opacity(viewModel.canGoPrevious ? 1 : 0.3)

                    Spacer()

                    Text(viewModel.paginationLabel)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    Spacer()

                    Button(action: viewModel.goNext) {
                        Text("›").font(.system(size: 20, weight: .semibold))
                            .frame(width: 32, height: 32)
                    }
                    .disabled(!viewModel.canGoNext)
                    .opacity(viewModel.canGoNext ? 1 : 0.3)
                }
                .foregroundStyle(Asset.Color.mainColor.color)
            }
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.top, Layout.Spacing.s)
        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
    }
}
