//
//  WorkoutSettingsSheet.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import SwiftUI

struct WorkoutSettingsSheet: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Layout.Spacing.l) {
            header

            switch viewModel.panel {
            case .overview: overviewPanel
            case .songList: songListPanel
            case .restTimer: restTimerPanel
            case .countdown: countdownPanel
            }

            Spacer()
        }
        .padding(Layout.Spacing.m)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            if viewModel.panel != .overview {
                Button {
                    viewModel.panel = .overview
                } label: {
                    Text("‹").font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Asset.Color.textPrimary.color)
                }
            }

            Text(headerTitle)
                .font(Typography.subtitleLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .frame(maxWidth: .infinity, alignment: viewModel.panel == .overview ? .leading : .center)

            Button {
                dismiss()
            } label: {
                Asset.Icon.Commo.xmark.image
                    .toIcon(Layout.Icon.small)
            }
        }
    }

    private var headerTitle: String {
        switch viewModel.panel {
        case .overview: "Workout Setting"
        case .songList: "Song List"
        case .restTimer: "Rest timer"
        case .countdown: "Countdown before workout"
        }
    }

    // MARK: - Overview

    private var overviewPanel: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.l) {
            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                Text("Music")
                    .font(Typography.captionMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                HStack {
                    Text(viewModel.selectedTrack.title)
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                    Spacer()
                    Text("‹  ▶  ›")
                        .font(.system(size: 14))
                        .foregroundStyle(Asset.Color.mainColor.color)
                }

                Button("See All Songs") { viewModel.panel = .songList }
                    .font(Typography.labelMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)

                HStack {
                    Text("Music Volume")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                    Spacer()
                    Text("\(Int(viewModel.settings.musicVolume * 100))%")
                        .font(Typography.captionMedium)
                        .foregroundStyle(Asset.Color.textSecondary.color)
                }
                Slider(value: $viewModel.settings.musicVolume, in: 0...1)
                    .tint(Asset.Color.mainColor.color)
            }

            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                Text("Duration")
                    .font(Typography.captionMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                settingsRow(
                    title: "Rest timer",
                    value: viewModel.settings.restTimerEnabled ? "\(viewModel.settings.restTimerSeconds)s" : "Off",
                    action: { viewModel.panel = .restTimer }
                )
                settingsRow(
                    title: "Countdown before workout",
                    value: "\(viewModel.settings.preWorkoutCountdownSeconds)s",
                    action: { viewModel.panel = .countdown }
                )
            }
        }
    }

    private func settingsRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)
                Spacer()
                Text(value)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textSecondary.color)
                Text("›")
                    .foregroundStyle(Asset.Color.textSecondary.color)
            }
            .padding(Layout.Spacing.s)
            .background(Asset.Color.bgSecondary.color)
            .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Song list

    private var songListPanel: some View {
        VStack(spacing: Layout.Spacing.m) {
            VStack(spacing: Layout.Spacing.s) {
                ForEach(viewModel.tracks) { track in
                    Button {
                        viewModel.selectTrack(track)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title)
                                    .font(Typography.bodyLarge)
                                    .foregroundStyle(Asset.Color.textPrimary.color)
                                Text(track.durationLabel)
                                    .font(Typography.captionSmall)
                                    .foregroundStyle(Asset.Color.textSecondary.color)
                            }
                            Spacer()
                            if track.id == viewModel.settings.selectedTrackId {
                                Asset.Icon.Commo.checkmarkCircle.image.toIcon(Layout.Icon.large)
                            }
                        }
                        .padding(Layout.Spacing.s)
                        .overlay {
                            RoundedRectangle(cornerRadius: Layout.CornerRadius.medium)
                                .stroke(
                                    track.id == viewModel.settings.selectedTrackId
                                        ? Asset.Color.mainColor.color : .clear,
                                    lineWidth: 1.5
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            primaryButton("Save", action: viewModel.confirmTrack)
        }
    }

    // MARK: - Rest timer

    private var restTimerPanel: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.m) {
            Toggle("Rest timer", isOn: $viewModel.settings.restTimerEnabled)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textPrimary.color)
                .tint(Asset.Color.mainColor.color)

            Text("Set the reset time between exercise")
                .font(Typography.captionMedium)
                .foregroundStyle(Asset.Color.textSecondary.color)

            HStack(spacing: Layout.Spacing.s) {
                ForEach([10, 15], id: \.self) { seconds in
                    optionPill(title: "\(seconds)s", isSelected: viewModel.settings.restTimerSeconds == seconds) {
                        viewModel.settings.restTimerSeconds = seconds
                    }
                }
            }
            .opacity(viewModel.settings.restTimerEnabled ? 1 : 0.4)
            .disabled(!viewModel.settings.restTimerEnabled)

            primaryButton("Done", action: viewModel.confirmRestTimer)
        }
    }

    // MARK: - Countdown

    private var countdownPanel: some View {
        VStack(spacing: Layout.Spacing.m) {
            HStack(spacing: Layout.Spacing.s) {
                ForEach([5, 10, 15], id: \.self) { seconds in
                    optionPill(title: "\(seconds)s", isSelected: viewModel.settings.preWorkoutCountdownSeconds == seconds) {
                        viewModel.settings.preWorkoutCountdownSeconds = seconds
                    }
                }
            }

            primaryButton("Done", action: viewModel.confirmCountdown)
        }
    }

    // MARK: - Shared pieces

    private func optionPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(isSelected ? Asset.Color.white.color : Asset.Color.textPrimary.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.Spacing.s)
                .background(isSelected ? Asset.Color.mainColor.color : Asset.Color.bgSecondary.color)
                .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.medium))
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.white.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.Spacing.m)
                .background(Asset.Color.mainColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
