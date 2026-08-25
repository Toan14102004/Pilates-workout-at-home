//
//  DiscoverWorkoutView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 25/8/26.
//

import SwiftUI

/// A workout opened from Discover. Unlike a program day, its exercise list starts locked: the
/// rows show only their position until the user watches a rewarded ad or subscribes.
struct DiscoverWorkoutView: View {
    // Observed, not read: the lock state is derived from the subscription, and buying premium
    // happens on a screen presented over this one. Without this the list would still be drawn
    // locked when the user came back.
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel: ViewModel

    init(workoutId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(workoutId: workoutId))
    }

    var body: some View {
        VStack(spacing: 0) {
            hero

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.Spacing.l) {
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
        .popup(isPresented: $viewModel.showUnlockDialog) {
            WorkoutUnlockDialog(
                getPremium: viewModel.openPremium,
                watchAds: viewModel.unlockWithAds,
                close: viewModel.dismissUnlockDialog
            )
        } customize: { params in
            params
                .centerPopup()
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(Layout.Opacity.semiTransparent))
        }
        .trackScreen("discoverWorkoutVC")
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack(alignment: .top) {
            // Runs edge to edge behind the status bar, so its height carries the safe-area inset
            // on top of the 220pt the design shows below it.
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
    }

    // MARK: - Content

    @ViewBuilder
    private func content(_ day: WorkoutDay) -> some View {
        Text(day.title)
            .font(.custom("Didot-Bold", size: 24))
            .foregroundStyle(Asset.Color.textPrimary.color)

        WorkoutStatsRow(day: day)

        if !day.summary.isEmpty {
            description(day.summary)
        }

        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            Text("Exercises (\(day.displayExerciseCount))")
                .font(Typography.subtitleSmall)
                .foregroundStyle(Asset.Color.textPrimary.color)

            if viewModel.isUnlocked {
                exerciseList(day)
            } else {
                lockedList
            }
        }
    }

    private func description(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
            Text(text)
                .font(Typography.bodySmall)
                .foregroundStyle(Asset.Color.textSecondary.color)
                .lineLimit(viewModel.isDescriptionExpanded ? nil : viewModel.collapsedDescriptionLines)
                .fixedSize(horizontal: false, vertical: true)

            Button(viewModel.isDescriptionExpanded ? "see less" : "see more",
                   action: viewModel.toggleDescription)
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.mainColor.color)
        }
    }

    private func exerciseList(_ day: WorkoutDay) -> some View {
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

    private var lockedList: some View {
        VStack(spacing: Layout.Spacing.m) {
            ForEach(1 ... max(viewModel.lockedRowCount, 1), id: \.self) { position in
                LockedExerciseRow(position: position, action: viewModel.requestUnlock)
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        Button(action: viewModel.startOrUnlock) {
            HStack(spacing: Layout.Spacing.s) {
                if !viewModel.isUnlocked {
                    Asset.Icon.Discover.lockWhite.image
                        .toIcon(Layout.Icon.small)
                }

                Text(viewModel.footerTitle)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.white.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.Spacing.m)
            .background(Asset.Color.mainColor.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, Layout.Spacing.m)
        .padding(.top, Layout.Spacing.s)
    }
}
