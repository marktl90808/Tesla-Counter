//  ContentView.swift
//  Tesla Counter
//
//  Started by Mark Leonard on 2/1/2024.
//
// ContentView.swift iOS Developer directory.
// Tesla Counter
// Working: Sound-tada,Tesla, oops, ding, Cybertruck
// Not Working yet - User provided sounds, images, override counts
// AI generated code for Tesla Counter.
import SwiftUI
import AVFoundation
import Combine

// The main view of app.
struct ContentView: View {
    @ObservedObject var viewModel = TapCountViewModel()
    @State private var showAlert = false // Define showAlert as a @State property
    @State var currentDate: Date = Date()
    let userDefaultsKey = "Tap"
    
    @State var showUserDefaultsData = false
    @State public var dateInput = ""
    @State public var countInput = ""
    @State var userDefaultsData: [DailyCount] = []
    // Removed: @State private var showHistory = false
    
    // Initialization
    init() {
        viewModel.t = UserDefaults.standard.integer(forKey: userDefaultsKey) // Set the tapCount
        
        // Fetch count for current day from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let existingCounts = try? JSONDecoder().decode([Date: Int].self, from: data) {
            if let countForToday = existingCounts[currentDate] {
                viewModel.t = countForToday
            }
        }
        
        if UserDefaults.standard.integer(forKey: "CelebrationMultiple") == 0 {
            UserDefaults.standard.set(10, forKey: "CelebrationMultiple")
        }
    }

    //MARK: Not in Chat GPT code ->
    var numberOfEntries: Int { return userDefaultsData.count }
    
    @State var currentImageIndex = 0
    
    @State public var storedCounts: [Date: Int] = [:]
    @State public var overrideCount: String = ""
    
    // Audio players for sound effects
    @State var iSoundOn: Bool = true
    @State var player: AVAudioPlayer?
    @State var teslaPlayer: AVAudioPlayer?
    @State var tadaPlayer: AVAudioPlayer?
    @State var oopsPlayer: AVAudioPlayer?
    @State var dingPlayer: AVAudioPlayer?
    
    // Recording and custom sound state
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording: Bool = false
    @State private var customSoundURL: URL? = UserDefaults.standard.url(forKey: "CustomSoundURL")
    @State private var customSoundName: String = UserDefaults.standard.string(forKey: "CustomSoundName") ?? ""
    
    // CT custom sound state
    @State private var ctAudioRecorder: AVAudioRecorder?
    @State private var isCTRecording: Bool = false
    @State private var customCTSoundURL: URL? = UserDefaults.standard.url(forKey: "CustomCTSoundURL")
    @State private var customCTSoundName: String = UserDefaults.standard.string(forKey: "CustomCTSoundName") ?? ""
    
    @State private var showSplash: Bool = true
    @State private var showPreferences = false
    @State private var celebrationMultiple: Int = UserDefaults.standard.integer(forKey: "CelebrationMultiple") == 0 ? 10 : UserDefaults.standard.integer(forKey: "CelebrationMultiple")
    
    
    func updateCountForDate(_ date: Date, count: Int) {
// Retrieve existing data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           var existingCounts = try? JSONDecoder().decode([Date: Int].self, from: data) {
// Update count for the specified date
            existingCounts[date] = count
            
// Save the updated data back to UserDefaults
            if let encodedCounts = try? JSONEncoder().encode(existingCounts) {
                UserDefaults.standard.set(encodedCounts, forKey: userDefaultsKey)
            }
        }
    }
    
    let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    func saveOverrideCount() {
        if let newCount = Int(overrideCount) {
            UserDefaults.standard.set(newCount, forKey: userDefaultsKey)
            viewModel.t = newCount
            viewModel.saveCounts()
        }
    }
    func storeCount(for date: Date, count: Int) {
        storedCounts[date] = count
    }
    func playSound(soundName: String) {
        guard iSoundOn else { return }
        // Try common extensions and locations (with and without Sounds subdirectory)
        let extensions = ["mp3", "mpg"]
        var foundURL: URL? = nil
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Sounds") {
                foundURL = url
                break
            }
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                foundURL = url
                break
            }
        }
        guard let url = foundURL else {
            print("Sound file not found: \(soundName) with extensions .mp3/.mpg")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    func playSound(for tapCount: Int) {
        guard iSoundOn else { return }
        let soundName = viewModel.t % 10 == 0 ? "tada" : "Tesla"
        print("The count is \(viewModel.t) so I'm Playing sound: \(soundName)")
        let extensions = ["mp3", "mpg"]
        var foundURL: URL? = nil
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Sounds") {
                foundURL = url
                break
            }
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                foundURL = url
                break
            }
        }
        guard let url = foundURL else {
            print("Error sound: file not found for \(soundName) with extensions .mp3/.mpg")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error sound: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Custom Sound Helpers
    func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func beginRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                guard granted else {
                    print("Microphone permission denied")
                    return
                }
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    try session.setActive(true)

                    let filename = "customSound.m4a"
                    let url = documentsDirectory().appendingPathComponent(filename)

                    let settings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]

                    audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                    audioRecorder?.prepareToRecord()
                    audioRecorder?.record()
                    isRecording = true
                } catch {
                    print("Failed to start recording: \(error)")
                }
            }
        }
    }

    func stopRecording(saveAs name: String?) {
        audioRecorder?.stop()
        isRecording = false
        guard let url = audioRecorder?.url else { return }
        let displayName = (name?.isEmpty == false) ? name! : url.lastPathComponent
        customSoundURL = url
        customSoundName = displayName
        UserDefaults.standard.set(url, forKey: "CustomSoundURL")
        UserDefaults.standard.set(displayName, forKey: "CustomSoundName")
        audioRecorder = nil
    }

    func removeCustomSound() {
        if let url = customSoundURL {
            try? FileManager.default.removeItem(at: url)
        }
        customSoundURL = nil
        customSoundName = ""
        UserDefaults.standard.removeObject(forKey: "CustomSoundURL")
        UserDefaults.standard.removeObject(forKey: "CustomSoundName")
    }

    func playCustomOrDefault() {
        if let url = customSoundURL {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                return
            } catch {
                print("Error playing custom sound: \(error)")
            }
        }
        if viewModel.t.isMultiple(of: celebrationMultiple) {
            playSound(soundName: "tada")
        } else {
            playSound(soundName: "Tesla")
        }
    }

    func beginCTRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                guard granted else {
                    print("Microphone permission denied for CT recording")
                    return
                }
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                    try session.setActive(true)

                    let filename = "customCTSound.m4a"
                    let url = documentsDirectory().appendingPathComponent(filename)

                    let settings: [String: Any] = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]

                    ctAudioRecorder = try AVAudioRecorder(url: url, settings: settings)
                    ctAudioRecorder?.prepareToRecord()
                    ctAudioRecorder?.record()
                    isCTRecording = true
                } catch {
                    print("Failed to start CT recording: \(error)")
                }
            }
        }
    }

    func stopCTRecording(saveAs name: String?) {
        ctAudioRecorder?.stop()
        isCTRecording = false
        guard let url = ctAudioRecorder?.url else { return }
        let displayName = (name?.isEmpty == false) ? name! : url.lastPathComponent
        customCTSoundURL = url
        customCTSoundName = displayName
        UserDefaults.standard.set(url, forKey: "CustomCTSoundURL")
        UserDefaults.standard.set(displayName, forKey: "CustomCTSoundName")
        ctAudioRecorder = nil
    }

    func removeCustomCTSound() {
        if let url = customCTSoundURL {
            try? FileManager.default.removeItem(at: url)
        }
        customCTSoundURL = nil
        customCTSoundName = ""
        UserDefaults.standard.removeObject(forKey: "CustomCTSoundURL")
        UserDefaults.standard.removeObject(forKey: "CustomCTSoundName")
    }

    func playCustomCTOrDefault() {
        guard iSoundOn else { return }
        if let url = customCTSoundURL {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                return
            } catch {
                print("Error playing custom CT sound: \(error)")
            }
        }
        playSound(soundName: "Cybertruck")
    }
    
    func toggleSound() {
        iSoundOn.toggle()
    }
    
    //    MARK: var body: some View
    var body: some View {
        
        ZStack {
            NavigationStack {
                VStack {
                    
                    Image("teslaLogo")
                        .resizable().aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            showPreferences = true
                        }
                    // MARK: the override sheet
       
                    // MARK: after the override sheet
                                    Image("tc.\(currentImageIndex)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .onTapGesture {
                                            viewModel.incrementCountForToday()
                                            playCustomOrDefault()
                                            currentImageIndex = (currentImageIndex + 1) % 19
                                            UserDefaults.standard.set(viewModel.t, forKey: "Tap")
                                            storeCount(for: currentDate, count: viewModel.t)
                                            viewModel.saveCounts()
                                        }
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(iSoundOn ? " 🔈 ON " : " 🔇 Off") {
                                        toggleSound()
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(iSoundOn ? .green : .red)
                                    Spacer()
                                    Button(action: {
                                        viewModel.incrementCTForToday()
                                        playCustomCTOrDefault()
                                    }) {
                                        Image("ct")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 96, height: 96)
                                    }
                                    .accessibilityLabel("Add CT")
                                    .buttonStyle(.plain)
                                    Spacer()
                                    Text("Oops").foregroundColor(.red)
                                        .onTapGesture {
                                            playSound(soundName: "oops")
                                            viewModel.decrementCountForToday()
                                            print("Teslas: \(viewModel.t)")
                                        }
                                    Spacer()
                                }
                
    // Footer with tap count and buttons
                HStack {
                    Spacer()
                    Text("Teslas: \(viewModel.t)")
                        .onTapGesture {
                            playSound(soundName: "ding")
                            viewModel.saveCounts()
                            showAlert = true
                        }
                        .foregroundColor(.red)
    //                    .padding(1)
                        Spacer()
                    Text("CT: \(viewModel.ct)")
                        .foregroundColor(.green)
    //                    .padding(1)
                    Spacer()
                    NavigationLink("History") {
                        CountHistoryView(viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
    //                .padding(0)
                        Spacer()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text("The UserDefaults data was updated."), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showPreferences) {
                Form {
                    // Keep the existing sections and content exactly as-is
                        Section(header: Text("Override Quantity")) {
                            Stepper(value: $celebrationMultiple, in: 1...500) {
                                HStack {
                                    Text("Celebrate every")
                                    Spacer()
                                    Text("\(celebrationMultiple)")
                                        .monospacedDigit()
                                        .foregroundColor(.secondary)
                                }
                            }
                            Text("When Teslas count reaches a multiple of this number, the 'tada' sound plays. Otherwise, 'Tesla' plays.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Section(header: Text("Custom Sound")) {
                            if customSoundName.isEmpty == false {
                                HStack {
                                    Text("Current:")
                                    Spacer()
                                    Text(customSoundName).foregroundColor(.secondary)
                                }
                            } else {
                                Text("No custom sound set")
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 16) {
                                Button(isRecording ? "Stop Recording" : "Record") {
                                    if isRecording {
                                        stopRecording(saveAs: customSoundName)
                                    } else {
                                        beginRecording()
                                    }
                                }
                                .buttonStyle(.borderedProminent)

                                if customSoundURL != nil {
                                    Button("Play") {
                                        playCustomOrDefault()
                                    }
                                    .buttonStyle(.bordered)

                                    Button(role: .destructive) {
                                        removeCustomSound()
                                    } label: {
                                        Text("Remove")
                                    }
                                }
                            }

                            TextField("Custom name (optional)", text: $customSoundName)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                        }
                        Section(header: Text("Custom CT Sound")) {
                            if customCTSoundName.isEmpty == false {
                                HStack {
                                    Text("Current:")
                                    Spacer()
                                    Text(customCTSoundName).foregroundColor(.secondary)
                                }
                            } else {
                                Text("No custom CT sound set")
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 16) {
                                Button(isCTRecording ? "Stop Recording" : "Record") {
                                    if isCTRecording {
                                        stopCTRecording(saveAs: customCTSoundName)
                                    } else {
                                        beginCTRecording()
                                    }
                                }
                                .buttonStyle(.borderedProminent)

                                if customCTSoundURL != nil {
                                    Button("Play") {
                                        playCustomCTOrDefault()
                                    }
                                    .buttonStyle(.bordered)

                                    Button(role: .destructive) {
                                        removeCustomCTSound()
                                    } label: {
                                        Text("Remove")
                                    }
                                }
                            }

                            TextField("Custom CT name (optional)", text: $customCTSoundName)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                        }
                        Section {
                            Button(role: .none) {
                                showPreferences = false
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Close Preferences")
                                    Spacer()
                                }
                            }
                        }
                }
                .navigationTitle("Preferences")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showPreferences = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            UserDefaults.standard.set(celebrationMultiple, forKey: "CelebrationMultiple")
                            if let url = customSoundURL {
                                UserDefaults.standard.set(url, forKey: "CustomSoundURL")
                            }
                            UserDefaults.standard.set(customSoundName, forKey: "CustomSoundName")
                            if let ctURL = customCTSoundURL {
                                UserDefaults.standard.set(ctURL, forKey: "CustomCTSoundURL")
                            }
                            UserDefaults.standard.set(customCTSoundName, forKey: "CustomCTSoundName")
                            showPreferences = false
                        }
                    }
                }
            }
            
            // Splash overlay
            if showSplash {
                Color(.systemBackground)
                    .ignoresSafeArea()
                Image("tc.0")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400)
                    .padding()
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.loadCounts()
            let saved = UserDefaults.standard.integer(forKey: "CelebrationMultiple")
            if saved > 0 { celebrationMultiple = saved }
            
            customSoundURL = UserDefaults.standard.url(forKey: "CustomSoundURL")
            customSoundName = UserDefaults.standard.string(forKey: "CustomSoundName") ?? ""
            customCTSoundURL = UserDefaults.standard.url(forKey: "CustomCTSoundURL")
            customCTSoundName = UserDefaults.standard.string(forKey: "CustomCTSoundName") ?? ""
            
            // Removed loading customSoundURL, customSoundName, customCTSoundURL, customCTSoundName since handled by SoundRecorder
            
            // Dismiss splash after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}
                
//                // MARK: after the override sheet



extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Preview for the ContentView.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

