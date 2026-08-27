//
//  WorkoutSettingsView.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// Figma: FLow Profile / 04 — Workout Settings.
struct WorkoutSettingsView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavBar(title: "Workout Settings", onBack: viewModel.back)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Layout.Spacing.m) {
                    section("Music") {
                        musicCard
                        volumeCard
                    }

                    section("Duration") {
                        durationRow(title: "Rest timer", value: viewModel.settings.restTimer.title) {
                            viewModel.editingDuration = .restTimer
                        }
                        durationRow(title: "Countdown before workout", value: viewModel.settings.countdown.title) {
                            viewModel.editingDuration = .countdown
                        }
                    }

                    PreloadedNativeAdsView(adKey: .profileMedium, style: .medium, height: NativeAdViewStyle.medium.height)
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: viewModel.load)
        .sheet(item: $viewModel.editingDuration) { field in
            durationPicker(for: field)
        }
        .trackScreen("workoutSettingsVC")
    }

    // MARK: - Sections

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.s + Layout.Spacing.xs) {
            Text(title)
                .font(Typography.bodyLarge)
                .foregroundStyle(Asset.Color.textSecondary.color)

            VStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var musicCard: some View {
        HStack(spacing: Layout.Spacing.m) {
            VStack(alignment: .leading, spacing: Layout.Spacing.s) {
                HStack(spacing: 2) {
                    Asset.Icon.Profile.soundWave.image
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text(viewModel.settings.songTitle)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .lineLimit(1)
                }

                Text("See All Songs")
                    .font(FontFamily.Inter.medium.font(size: 12))
                    .foregroundStyle(Asset.Color.mainColor.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                controlButton(Asset.Icon.ProfileSetup.backChevron.image, size: 16)

                Button(action: viewModel.togglePlayback) {
                    Asset.Icon.Profile.playPause.image
                        .resizable()
                        .frame(width: 24, height: 24)
                }

                controlButton(Asset.Icon.Profile.chevronRight.image, size: 16)
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
        .frame(height: 72)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private func controlButton(_ image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .frame(width: size, height: size)
            .padding(Layout.Spacing.xs)
            .frame(width: 26, height: 26)
            .background(Asset.Color.white.color)
            .clipShape(Circle())
    }

    private var volumeCard: some View {
        VStack(spacing: Layout.Spacing.l) {
            HStack {
                Text("Music Volume")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer()

                Text(viewModel.settings.volumePercentText)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.mainColor.color)
            }

            HStack(spacing: Layout.Spacing.m) {
                Asset.Icon.Profile.volumeMin.image
                    .resizable()
                    .frame(width: 24, height: 24)

                Slider(value: $viewModel.settings.musicVolume, in: 0...1)
                    .tint(Asset.Color.mainColor.color)

                Asset.Icon.Profile.volumeMax.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private func durationRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Asset.Color.textPrimary.color)

                Spacer(minLength: Layout.Spacing.m)

                Text(value)
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                Asset.Icon.Profile.chevronRight.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, Layout.Spacing.s + Layout.Spacing.xs)
            .frame(height: 56)
            .background(Asset.Color.white.color)
            .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
        }
        .buttonStyle(.plain)
    }

    /// The design has no frame for picking these values, so this is a plain list sheet.
    @ViewBuilder
    private func durationPicker(for field: ViewModel.DurationField) -> some View {
        NavigationView {
            List {
                switch field {
                case .restTimer:
                    ForEach(RestTimerDuration.allCases) { option in
                        durationOption(option.title, isOn: viewModel.settings.restTimer == option) {
                            viewModel.settings.restTimer = option
                            viewModel.editingDuration = nil
                        }
                    }
                case .countdown:
                    ForEach(WorkoutCountdown.allCases) { option in
                        durationOption(option.title, isOn: viewModel.settings.countdown == option) {
                            viewModel.settings.countdown = option
                            viewModel.editingDuration = nil
                        }
                    }
                }
            }
            .navigationTitle(field.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func durationOption(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundStyle(Asset.Color.textPrimary.color)
                Spacer()
                if isOn {
                    Asset.Icon.Profile.tickCircle.image
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    WorkoutSettingsView()
        .preview()
}
