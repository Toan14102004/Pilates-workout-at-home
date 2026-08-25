//
//  WorkoutScheduleView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

/// The program's day-by-day schedule: a timeline of days grouped into phases, with the day the
/// user is on highlighted.
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
                    PreloadedNativeAdsView(adKey: .practiceCompact,
                                           style: .contentCard,
                                           height: NativeAdViewStyle.contentCard.height)

                    if viewModel.isLoading, viewModel.plan == nil {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, Layout.Spacing.xxl)
                    } else if let errorMessage = viewModel.errorMessage, viewModel.plan == nil {
                        WorkoutErrorView(message: errorMessage, retry: viewModel.load)
                    } else if let plan = viewModel.plan {
                        overallProgress

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

    private var overallProgress: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.xs) {
            Text(viewModel.progressLabel)
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)

            progressBar(viewModel.progressFraction, height: 4)
        }
    }

    private func progressBar(_ fraction: Double, height: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Asset.Color.bgSecondary.color)
                Capsule()
                    .fill(Asset.Color.mainColor.color)
                    .frame(width: max(geometry.size.width * fraction, fraction > 0 ? 6 : 0))
            }
        }
        .frame(height: height)
    }

    // MARK: - Phase

    @ViewBuilder
    private func phaseSection(_ phase: WorkoutPhase) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s) {
            // Programs the API ships without phases get no header: with a single section it would
            // just restate the progress line directly above it.
            if let number = phase.number {
                HStack(spacing: Layout.Spacing.xs) {
                    Text("Phase \(number)")
                        .font(Typography.subtitleSmall)
                        .foregroundStyle(Asset.Color.textPrimary.color)

                    Text(phase.name)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Asset.Color.textSecondary.color)

                    Spacer()

                    Text("\(Int(viewModel.phaseProgress(phase) * 100))%")
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(phase.days.enumerated()), id: \.element.id) { position, day in
                    dayRow(day, showsConnector: position < phase.days.count - 1)
                }
            }
        }
    }

    // MARK: - Day row

    private func dayRow(_ day: WorkoutDay, showsConnector: Bool) -> some View {
        let state = viewModel.state(for: day)
        let fraction = viewModel.dayProgress(day)

        return HStack(alignment: .top, spacing: Layout.Spacing.s) {
            timeline(state: state, showsConnector: showsConnector)

            Button {
                viewModel.openDay(day)
            } label: {
                HStack(spacing: Layout.Spacing.s) {
                    RemoteImageView(url: day.imageUrl)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(day.title)
                            .font(Typography.subtitleSmall)
                            .foregroundStyle(Asset.Color.textPrimary.color)

                        subtitle(for: day, state: state, fraction: fraction)
                    }

                    Spacer(minLength: Layout.Spacing.xs)

                    trailing(for: state)
                }
                .padding(Layout.Spacing.s)
                .background(state == .current ? Asset.Color.white.color : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
                .overlay {
                    if state == .current {
                        RoundedRectangle(cornerRadius: Layout.CornerRadius.large)
                            .stroke(Asset.Color.mainColor.color, lineWidth: 1.5)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(day.isRestDay)
        }
        .padding(.bottom, Layout.Spacing.xs)
    }

    /// The connected circles running down the left edge.
    private func timeline(state: WorkoutDayState, showsConnector: Bool) -> some View {
        VStack(spacing: 0) {
            ZStack {
                switch state {
                case .finished:
                    Circle().fill(Asset.Color.mainColor.color)
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Asset.Color.white.color)
                case .current:
                    Circle().stroke(Asset.Color.mainColor.color, lineWidth: 2)
                case .upcoming:
                    Circle().stroke(Asset.Color.borderPrimary.color, lineWidth: 1.5)
                }
            }
            .frame(width: 16, height: 16)
            .padding(.top, Layout.Spacing.m)

            if showsConnector {
                Rectangle()
                    .fill(Asset.Color.borderPrimary.color)
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 16)
    }

    @ViewBuilder
    private func subtitle(for day: WorkoutDay, state: WorkoutDayState, fraction: Double) -> some View {
        if day.isRestDay {
            caption("Rest day")
        } else if state == .finished {
            caption("Finished!")
        } else if fraction > 0 {
            // Started but unfinished days show how far in the user got.
            HStack(spacing: Layout.Spacing.xs) {
                progressBar(fraction, height: 3).frame(width: 90)
                caption("\(Int(fraction * 100))%")
            }
        } else {
            caption(day.exerciseCountLabel)
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(Typography.captionMedium)
            .foregroundStyle(Asset.Color.textSecondary.color)
    }

    @ViewBuilder
    private func trailing(for state: WorkoutDayState) -> some View {
        switch state {
        case .finished:
            Asset.Icon.Commo.checkmarkCircle.image.toIcon(Layout.Icon.medium)
        case .current, .upcoming:
            Image(systemName: "play.fill")
                .font(.system(size: 11))
                .foregroundStyle(state == .current ? Asset.Color.white.color : Asset.Color.mainColor.color)
                .frame(width: Layout.Icon.medium, height: Layout.Icon.medium)
                .background(state == .current ? Asset.Color.mainColor.color : Color.clear)
                .clipShape(Circle())
                .overlay {
                    if state == .upcoming {
                        Circle().stroke(Asset.Color.mainColor.color, lineWidth: 1.5)
                    }
                }
        }
    }
}
