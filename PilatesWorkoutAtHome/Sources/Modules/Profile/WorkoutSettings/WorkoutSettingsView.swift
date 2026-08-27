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
                        playbackBar
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

                    PreloadedNativeAdsView(adKey: .profileMedium, style: .contentCard, height: NativeAdViewStyle.contentCard.height)
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
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.isPickingSong) {
            songPicker
                .presentationDetents([.medium])
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

                Button {
                    viewModel.isPickingSong = true
                } label: {
                    Text("See All Songs")
                        .font(FontFamily.Inter.medium.font(size: 12))
                        .foregroundStyle(Asset.Color.mainColor.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Layout.Spacing.s + Layout.Spacing.xs) {
                Button(action: viewModel.previousTrack) {
                    controlButton(Asset.Icon.ProfileSetup.backChevron.image, size: 16)
                }

                Button(action: viewModel.togglePlayback) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Asset.Color.textPrimary.color)
                        .frame(width: 26, height: 26)
                        .background(Asset.Color.white.color)
                        .clipShape(Circle())
                }

                Button(action: viewModel.nextTrack) {
                    controlButton(Asset.Icon.Profile.chevronRight.image, size: 16)
                }
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
        .frame(height: 72)
        .background(Asset.Color.white.color)
        .clipShape(RoundedRectangle(cornerRadius: Layout.CornerRadius.large))
    }

    private var playbackBar: some View {
        VStack(spacing: Layout.Spacing.m) {
            Slider(value: $viewModel.currentTime, in: 0...max(viewModel.duration, 1))
                .tint(Asset.Color.mainColor.color)
                .onChange(of: viewModel.currentTime) { _ in
                    if viewModel.duration > 0 {
                        viewModel.seek(to: viewModel.currentTime)
                    }
                }

            HStack {
                Text(formatTime(viewModel.currentTime))
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.textSecondary.color)

                Spacer()

                Text(formatTime(viewModel.duration))
                    .font(Typography.bodySmall)
                    .foregroundStyle(Asset.Color.textSecondary.color)
            }
        }
        .padding(Layout.Spacing.s + Layout.Spacing.xs)
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
        .colorScheme(.light)
    }

    private var songPicker: some View {
        NavigationView {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.tracks) { track in
                    Button {
                        viewModel.selectTrack(track)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(track.title)
                                    .foregroundStyle(Asset.Color.textPrimary.color)
                                Text(track.author)
                                    .font(Typography.bodySmall)
                                    .foregroundStyle(Asset.Color.textSecondary.color)
                                Text(track.durationFormatted)
                                    .font(Typography.captionSmall)
                                    .foregroundStyle(Asset.Color.textTertiary.color)
                            }
                            Spacer()
                            if track.title == viewModel.settings.songTitle {
                                Asset.Icon.Profile.tickCircle.image
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
                .navigationTitle("Songs")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .colorScheme(.light)
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

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
    WorkoutSettingsView()
        .preview()
}
