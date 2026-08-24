//
//  ExerciseVideoPlayer.swift
//  PilatesWorkoutAtHome
//
//  Created by Toan Nguyen on 24/8/26.
//

import AVFoundation
import Combine
import SwiftUI

/// Silent, looping demo clip for one exercise. The API serves short MP4s
/// (`media.videoUrl`, a few hundred KB), so this streams straight from the URL with no controls --
/// it reads as an animation rather than a video the user is meant to scrub.
struct ExerciseVideoPlayer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> LoopingPlayerView {
        let view = LoopingPlayerView()
        view.play(url: url)
        return view
    }

    func updateUIView(_ uiView: LoopingPlayerView, context _: Context) {
        uiView.play(url: url)
    }

    static func dismantleUIView(_ uiView: LoopingPlayerView, coordinator _: ()) {
        uiView.stop()
    }
}

final class LoopingPlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var looper: NSObjectProtocol?
    private var currentURL: URL?

    func play(url: URL) {
        guard url != currentURL else { return }
        currentURL = url
        stop()

        let player = AVPlayer(url: url)
        player.isMuted = true
        player.actionAtItemEnd = .none

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        // Seamless loop: rewind whenever the clip reaches its end.
        looper = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        player.play()
    }

    func stop() {
        if let looper {
            NotificationCenter.default.removeObserver(looper)
            self.looper = nil
        }
        playerLayer.player?.pause()
        playerLayer.player = nil
    }

    deinit {
        if let looper {
            NotificationCenter.default.removeObserver(looper)
        }
    }
}
