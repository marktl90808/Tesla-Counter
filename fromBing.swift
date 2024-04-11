//
//  fromBing.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 2/27/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var audioPlayer: AVAudioPlayer?
    var pausedAudioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a button
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play Sound", for: .normal)
        playButton.addTarget(self, action: #selector(playSound), for: .touchUpInside)
        playButton.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        view.addSubview(playButton)

        // Load your sound file from the Sounds folder (make sure it's in your app bundle)
        if let soundURL = Bundle.main.url(forResource: "Tesla", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound file: \(error.localizedDescription)")
            }
        }
    }

    @objc func playSound() {
        if let player = audioPlayer {
            if player.isPlaying {
                // Pause existing audio
                player.pause()
                pausedAudioPlayer = player
            } else {
                // Resume paused audio or play from the beginning
                if let pausedPlayer = pausedAudioPlayer {
                    pausedPlayer.play()
                } else {
                    player.play()
                }
            }
        }
    }
}
