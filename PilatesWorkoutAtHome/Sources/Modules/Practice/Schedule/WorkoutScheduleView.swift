//
//  WorkoutScheduleView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct WorkoutScheduleView: View {
    @StateObject private var viewModel: ViewModel

    init(programId: String) {
        _viewModel = StateObject(wrappedValue: ViewModel(programId: programId))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                RemoteImageView(url: viewModel.heroImageUrl)
                    .frame(width: UIScreen.main.bounds.width,
                           height: Layout.heroHeight + UIApplication.shared.safeAreaTop)

                HeroOverlayButton(image: Asset.Icon.Commo.arrowLeft, action: viewModel.back)
                    .padding(Layout.Spacing.m)
                    .padding(.top, UIApplication.shared.safeAreaTop)
            }
            .clipped()
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.Spacing.l) {
                    PreloadedNativeAdsView(adKey: .practiceCompact, style: .contentCard, height: NativeAdViewStyle.contentCard.height)

                    if viewModel.isLoading, viewModel.plan == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, Layout.Spacing.xxl)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.plan == nil {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else if let plan = viewModel.plan {
                        progressBar

                        ForEach(plan.phases) { phase in
                            phaseSection(phase)
                        }
                    }
                }
                .padding(Layout.Spacing.m)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: viewModel.loadIfNeeded)
        .trackScreen("workoutScheduleVC")
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xxs) {
            HStack {
                Spacer()
                Text(viewModel.progressLabel)
                    .font(Typography.captionMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
            }
            Capsule()
                .fill(Asset.Color.bgSecondary.color)
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    GeometryReader { geometry in
                        Capsule()
                            .fill(Asset.Color.mainColor.color)
                            .frame(width: geometry.size.width * viewModel.progressFraction)
                    }
                }
        }
    }

    private func phaseSection(_ phase: WorkoutPhase) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            HStack {
                Text(phase.title)
                    .font(Typography.subtitleSmall)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                Spacer()
                Text("\(Int(viewModel.phaseProgress(phase) * 100))%")
                    .font(Typography.captionMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
            }

            VStack(spacing: Layout.Spacing.m) {
                ForEach(phase.days) { day in
                    dayRow(day)
                }
            }
        }
    }

    private func dayRow(_ day: WorkoutDay) -> some View {
        let state = viewModel.state(for: day)

        return Button {
            viewModel.openDay(day)
        } label: {
            HStack(spacing: Layout.Spacing.s) {
                RemoteImageView(url: day.imageUrl)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))
                    .overlay {
                        if state == .current {
                            RoundedRectangle(cornerRadius: Layout.CornerRadius.medium)
                                .stroke(Asset.Color.mainColor.color, lineWidth: 2)
                        }
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(day.title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                    Text(subtitle(for: day, state: state))
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }

                Spacer()

                trailingIcon(for: state)
            }
        }
        .buttonStyle(.plain)
        .disabled(day.isRestDay)
    }

    private func subtitle(for day: WorkoutDay, state: WorkoutDayState) -> String {
        if day.isRestDay { return "Rest day" }
        return state == .finished ? "Finished!" : day.exerciseCountLabel
    }

    @ViewBuilder
    private func trailingIcon(for state: WorkoutDayState) -> some View {
        switch state {
        case .finished:
            Asset.Icon.Commo.checkmarkCircle.image.toIcon(Layout.Icon.medium)
        case .current:
            playGlyph.foregroundStyle(Asset.Color.white.color)
                .frame(width: Layout.Icon.medium, height: Layout.Icon.medium)
                .background(Asset.Color.mainColor.color)
                .clipShape(Circle())
        case .upcoming:
            playGlyph.foregroundStyle(Asset.Color.mainColor.color)
                .frame(width: Layout.Icon.medium, height: Layout.Icon.medium)
                .overlay(Circle().stroke(Asset.Color.mainColor.color, lineWidth: 1.5))
        }
    }

    private var playGlyph: some View {
        Text("▶")
            .font(.system(size: 12))
    }
}
