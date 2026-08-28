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

        /// Streams straight from the URL instead of downloading the whole track first --
        /// tracks run 3-28 minutes, so waiting on a full download would leave this screen
        /// silent for a long, connection-dependent stretch before any sound plays.
        private var player: AVPlayer?
        private var timeObserverToken: Any?
        private var endObserver: NSObjectProtocol?
        private var didActivateAudioSession = false
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
            } else if player != nil {
                player?.play()
                isPlaying = true
            } else {
                startPlayback()
            }
        }

        private func startPlayback() {
            guard let currentTrack, let url = URL(string: currentTrack.audioUrl) else { return }

            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("[BackgroundMusic] Failed to activate audio session: \(error)")
            }

            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            self.player = player

            item.publisher(for: \.duration)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] duration in
                    guard duration.isNumeric else { return }
                    self?.duration = duration.seconds
                }
                .store(in: &cancellables)

            timeObserverToken = player.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
                queue: .main
            ) { [weak self] time in
                self?.currentTime = time.seconds
            }

            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                self?.nextTrack()
            }

            isPlaying = true
            player.play()
        }

        private func pausePlayback() {
            isPlaying = false
            player?.pause()
        }

        private func stopPlayer() {
            if let timeObserverToken {
                player?.removeTimeObserver(timeObserverToken)
            }
            timeObserverToken = nil
            if let endObserver {
                NotificationCenter.default.removeObserver(endObserver)
            }
            endObserver = nil
            player?.pause()
            player = nil
            currentTime = 0
            duration = 0
        }

        func seek(to time: TimeInterval) {
            let clamped = max(0, min(time, duration))
            player?.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
            currentTime = clamped
        }

        func selectTrack(_ track: BackgroundMusic) {
            pausePlayback()
            stopPlayer()
            settings.songTitle = track.title
            isPickingSong = false
        }

        func previousTrack() {
            guard let currentTrack else { return }
            let index = tracks.firstIndex(where: { $0.id == currentTrack.id }) ?? 0
            let newTrack = tracks[(index - 1 + tracks.count) % tracks.count]
            selectTrack(newTrack)
        }

        func nextTrack() {
            guard let currentTrack else { return }
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
