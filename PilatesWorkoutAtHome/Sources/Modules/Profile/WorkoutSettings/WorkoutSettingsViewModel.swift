//
//  WorkoutSettingsViewModel.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 26/8/26.
//

import AVFoundation
import Combine
import SwiftUI

extension WorkoutSettingsView {
    final class ViewModel: BaseViewModel {
        @Navigation var navigation
        @Injected var localStorageService: LocalStorageService

        @Published var coordinator = Coordinator()
        @Published var settings = ProfileWorkoutSettings() {
            didSet { localStorageService.profileWorkoutSettings = settings }
        }

        @Published var editingDuration: DurationField?
        @Published var isPickingSong = false
        @Published var tracks: [BackgroundMusic] = []
        @Published var isPlaying = false
        @Published var currentTime: TimeInterval = 0
        @Published var duration: TimeInterval = 0
        @Published var isLoading = false

        private var audioPlayer: AVAudioPlayer?
        private var progressTimerCancellable: AnyCancellable?
        private var cancellables = Set<AnyCancellable>()
        private let backgroundMusicService = BackgroundMusicService.shared

        enum DurationField: Identifiable {
            case restTimer
            case countdown

            var id: Int { self == .restTimer ? 0 : 1 }

            var title: String {
                self == .restTimer ? "Rest timer" : "Countdown before workout"
            }
        }

        func load() {
            settings = localStorageService.profileWorkoutSettings
            loadBackgroundMusic()
        }

        private func loadBackgroundMusic() {
            isLoading = true
            backgroundMusicService.fetchBackgroundMusic()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                }, receiveValue: { [weak self] tracks in
                    self?.tracks = tracks
                    if let firstTrack = tracks.first {
                        self?.settings.songTitle = firstTrack.title
                    }
                })
                .store(in: &cancellables)
        }

        var currentTrack: BackgroundMusic? {
            tracks.first { $0.title == settings.songTitle }
        }

        func togglePlayback() {
            if isPlaying {
                pausePlayback()
            } else {
                startPlayback()
            }
        }

        private func startPlayback() {
            guard let currentTrack = currentTrack else { return }
            guard let url = URL(string: currentTrack.audioUrl) else { return }

            isPlaying = true
            downloadAndPlay(url: url)
        }

        private func pausePlayback() {
            isPlaying = false
            audioPlayer?.pause()
            stopProgressTimer()
        }

        private func downloadAndPlay(url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self, let data = data, error == nil else {
                    DispatchQueue.main.async { self?.isPlaying = false }
                    return
                }

                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)

                    let audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.mp3.rawValue)
                    DispatchQueue.main.async {
                        self.audioPlayer = audioPlayer
                        self.duration = audioPlayer.duration
                        audioPlayer.play()
                        self.startProgressTimer()
                    }
                } catch {
                    print("[BackgroundMusic] Failed to start playback: \(error)")
                    DispatchQueue.main.async { self.isPlaying = false }
                }
            }.resume()
        }

        private func startProgressTimer() {
            progressTimerCancellable = Timer.publish(every: 0.25, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.updatePlaybackTime()
                }
        }

        private func stopProgressTimer() {
            progressTimerCancellable?.cancel()
            progressTimerCancellable = nil
        }

        private func updatePlaybackTime() {
            guard let player = audioPlayer, isPlaying else { return }
            currentTime = player.currentTime
            if duration > 0 && currentTime >= duration - 0.1 {
                nextTrack()
            }
        }

        func seek(to time: TimeInterval) {
            audioPlayer?.currentTime = max(0, min(time, duration))
            currentTime = audioPlayer?.currentTime ?? 0
        }

        func selectTrack(_ track: BackgroundMusic) {
            pausePlayback()
            currentTime = 0
            settings.songTitle = track.title
            isPickingSong = false
        }

        func previousTrack() {
            guard let currentTrack = currentTrack else { return }
            let index = tracks.firstIndex(where: { $0.id == currentTrack.id }) ?? 0
            let newTrack = tracks[(index - 1 + tracks.count) % tracks.count]
            selectTrack(newTrack)
        }

        func nextTrack() {
            guard let currentTrack = currentTrack else { return }
            let index = tracks.firstIndex(where: { $0.id == currentTrack.id }) ?? 0
            let newTrack = tracks[(index + 1) % tracks.count]
            selectTrack(newTrack)
        }

        func back() {
            pausePlayback()
            navigation.goBack()
        }
    }
}

