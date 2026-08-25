//
//  WorkoutDayView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct WorkoutDayView: View {
    @StateObject private var viewModel: ViewModel

    init(workoutId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(workoutId: workoutId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // The hero runs edge to edge behind the status bar, so its height carries the
                // safe-area inset on top of the 220pt the design shows below it.
                RemoteImageView(url: viewModel.day?.imageUrl)
                    .frame(width: UIScreen.main.bounds.width,
                           height: Layout.heroHeight + UIApplication.shared.safeAreaTop)

                HStack {
                    HeroOverlayButton(image: Asset.Icon.Commo.arrowLeft, action: viewModel.back)
                    Spacer()
                    HeroOverlayTextButton(symbol: "⚙", action: viewModel.openSettings)
                }
                .padding(Layout.Spacing.m)
                .padding(.top, UIApplication.shared.safeAreaTop)
            }
            .clipped()
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                    if viewModel.isLoading, viewModel.day == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, Layout.Spacing.xxl)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.day == nil {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else if let day = viewModel.day {
                        content(day)
                    }
                }
                .padding(Layout.Spacing.m)
            }

            if viewModel.day != nil {
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .sheet(isPresented: $viewModel.showSettings) {
            WorkoutSettingsSheet(viewModel: .init())
                .presentationDetents([.medium, .large])
        }
        .trackScreen("workoutDayVC")
    }

    @ViewBuilder
    private func content(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
            Text(day.dayNumber > 0 ? "Day \(day.dayNumber)" : day.title)
                .font(.custom("Didot-Bold", size: 24))
                .foregroundStyle(Asset.Color.textPrimary.color)
            Text(day.planName)
                .font(Typography.bodySmall)
                .foregroundStyle(Asset.Color.textSecondary.color)
        }

        WorkoutStatsRow(day: day)

        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            Text("Exercises (\(day.displayExerciseCount))")
                .font(Typography.subtitleSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)

            VStack(spacing: Layout.Spacing.m) {
                ForEach(day.exercises) { exercise in
                    WorkoutExerciseRow(
                        imageUrl: exercise.imageUrl ?? day.imageUrl,
                        title: exercise.name,
                        subtitle: exercise.durationLabel,
                        isCompleted: viewModel.isCompleted(exercise),
                        action: { viewModel.openExercise(exercise) }
                    )
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: Layout.Spacing.s) {
            if viewModel.hasStarted {
                Button("Restart", action: viewModel.restart)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.mainColor.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.Spacing.m)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Asset.Color.mainColor.color, lineWidth: 1.5))
            }

            Button(viewModel.hasStarted ? "Continue" : "Start Now", action: viewModel.startOrContinue)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.Spacing.m)
                .background(Asset.Color.mainColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.top, Layout.Spacing.s)
//        .padding(.bottom, UIApplication.shared.safeAreaBottom + Layout.Spacing.s)
    }
}
