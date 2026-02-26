import SwiftUI
import AVFoundation

class SoundRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var displayName: String
    @Published var fileURL: URL?

    private let nameKey: String
    private let urlKey: String
    private let defaultFilename: String
    private var audioRecorder: AVAudioRecorder?

    init(nameKey: String, urlKey: String, defaultFilename: String) {
        self.nameKey = nameKey
        self.urlKey = urlKey
        self.defaultFilename = defaultFilename

        let defaults = UserDefaults.standard
        if let savedName = defaults.string(forKey: nameKey) {
            self.displayName = savedName
        } else {
            self.displayName = defaultFilename
        }
        if let urlString = defaults.string(forKey: urlKey),
           let url = URL(string: urlString) {
            self.fileURL = url
        } else {
            self.fileURL = nil
        }
    }

    func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            try session.setActive(true)

            let filename = UUID().uuidString + ".m4a"
            let url = SoundRecorder.documentsDirectory().appendingPathComponent(filename)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            // Failed to start recording
            isRecording = false
        }
    }

    func stopRecording(saveAs name: String? = nil) {
        audioRecorder?.stop()
        isRecording = false

        guard let recorder = audioRecorder else { return }
        let recordedURL = recorder.url

        fileURL = recordedURL

        if let name = name, !name.isEmpty {
            displayName = name
        } else {
            displayName = defaultFilename
        }

        let defaults = UserDefaults.standard
        defaults.set(displayName, forKey: nameKey)
        defaults.set(recordedURL.absoluteString, forKey: urlKey)
    }

    func removeRecording() {
        if let url = fileURL {
            try? FileManager.default.removeItem(at: url)
        }
        fileURL = nil
        displayName = defaultFilename

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: nameKey)
        defaults.removeObject(forKey: urlKey)
    }

    func play(using player: inout AVAudioPlayer?) {
        guard let url = fileURL else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            player = nil
        }
    }

    static func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
