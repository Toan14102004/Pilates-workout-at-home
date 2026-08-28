import AVFoundation
import Combine
import Foundation

/// Streams a single background-music track, shared by the pre-workout settings preview and the
/// live workout session so both drive one player instance instead of each managing (and possibly
/// overlapping) their own player.
///
/// Uses `AVPlayer` against the remote URL directly rather than downloading the whole file first --
/// tracks run 3-28 minutes (several MB to tens of MB), so a download-then-play approach leaves
/// the user hearing nothing for a long, connection-dependent stretch before playback can start.
///
/// The live workout session also renders ad units (native ads, and an interstitial around the
/// splash flow elsewhere in the app); ad SDKs commonly reconfigure the shared `AVAudioSession`
/// for their own video creatives, which can silently cut this player off from the audio route.
/// The interruption observer below exists specifically to survive that.
final class BackgroundMusicPlayer: ObservableObject {
    static let shared = BackgroundMusicPlayer()

    @Published private(set) var isPlaying = false

    private var player: AVPlayer?
    private var currentTrackId: String?
    private var loopObserver: NSObjectProtocol?
    private var interruptionObserver: NSObjectProtocol?
    private var pendingVolume: Float = 1

    init() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            self?.handleInterruption(notification)
        }
    }

    deinit {
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
    }

    /// - Parameter loop: Workout sessions run longer than any single track, so the session
    ///   player loops; a settings preview just plays through once.
    func play(_ track: BackgroundMusic, volume: Float, loop: Bool = false) {
        guard let url = URL(string: track.audioUrl) else { return }

        pendingVolume = volume
        activateAudioSession()

        if currentTrackId == track.id, let player {
            player.volume = volume
            player.play()
            isPlaying = true
            return
        }

        stop()
        currentTrackId = track.id

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.volume = volume
        self.player = player

        if loop {
            loopObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }

        player.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        guard player != nil else { return }
        activateAudioSession()
        player?.play()
        isPlaying = true
    }

    func setVolume(_ volume: Float) {
        pendingVolume = volume
        player?.volume = volume
    }

    /// Self-heals against silent, hard-to-pin-down interference (a video ad or the exercise demo
    /// clip's own player quietly resetting the shared `AVAudioSession`, without necessarily
    /// firing an interruption notification we'd otherwise catch). Cheap to call repeatedly --
    /// the workout session calls this every second while music should be playing.
    func ensurePlaying() {
        guard isPlaying, let player, player.rate == 0 else { return }
        activateAudioSession()
        player.volume = pendingVolume
        player.play()
    }

    func stop() {
        player?.pause()
        player = nil
        currentTrackId = nil
        isPlaying = false
        if let loopObserver {
            NotificationCenter.default.removeObserver(loopObserver)
        }
        loopObserver = nil
    }

    /// Re-asserts our category on every play/resume rather than once -- an ad SDK reconfiguring
    /// the shared session later would otherwise leave us silently stuck on whatever it set.
    ///
    /// Plain `.playback`, no options: `.playback` is the category documented to keep playing
    /// with the Ring/Silent switch set to silent, but pairing it with `.mixWithOthers` has been
    /// reported to fall back to respecting the switch on-device, which is exactly the silent
    /// workout session this exists to fix.
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            print("[BackgroundMusicPlayer] Failed to activate audio session: \(error)")
        }
    }

    /// Another audio source (an ad's video creative, a call, Siri) can interrupt the shared
    /// session out from under us. Reclaim it once that source is done, if we were mid-track.
    private func handleInterruption(_ notification: Notification) {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            isPlaying = false
        case .ended:
            guard player != nil else { return }
            let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            guard options.contains(.shouldResume) else { return }
            activateAudioSession()
            player?.volume = pendingVolume
            player?.play()
            isPlaying = true
        @unknown default:
            break
        }
    }
}
