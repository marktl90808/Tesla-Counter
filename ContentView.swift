//  ContentView.swift
//  Tesla Counter
//  Created by Mark Leonard on 3/25/2024.
// AI generated code for Tesla Counter. Images are same as old Tesla Counter.
//

import SwiftUI
import AVFAudio
import Foundation
extension Date {
    var withoutTime: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
}
struct ContentView: View {
    @ObservedObject var dailyCountsData = DailyCountsData()
    @State private var tapCount: Int = UserDefaults.standard.integer(forKey: "Tap")
    
    // MARK: Initialize the DailyCountsDataInject the shared data into the view
    @State private var showAscending = false
    
    @State private var userDefaultsValue: String = UserDefaults.standard.string(forKey: "Tap") ?? ""
    
    @AppStorage("storedCounts") var storedCountsData: Data = Data()
    @State private var storedCounts: [Date: Int] = [:]
    @State private var showCountList = false
    @State private var reverseOrder = false
    
    @State private var currentDate: Date = Date()
    @State private var isAscending = true
    @State private var showDailyCounts: Bool = false
    @State private var currentImageIndex = 0
    @State private var overrideCount: String = ""
    @State private var isShowingOverrideField: Bool = false
    @State private var isShowingList = false
    @State private var isSoundOn: Bool = true
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        NavigationStack {
            VStack {
                /*MARK: Comment out
                Image("TeslaLogo")
                    .resizable().aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        overrideCount = "\(tapCount)"
                        isShowingOverrideField.toggle()
                    }
                */
                Image("tc.\(currentImageIndex)")
                    .resizable().aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        tapCount += 1
                        playSound(for: tapCount)
                        currentImageIndex = (currentImageIndex + 1) % 19
                        storeCount(for: currentDate, count: tapCount)
                        UserDefaults.standard.set(tapCount, forKey: "Tap")
                        
                    }
                Button("Current/Daily Counts: \(tapCount)") {
                    showDailyCounts.toggle()
                }
                HStack {
                    Button(isSoundOn ? "Sound Off" : "Sound On") {
                        toggleSound()
                    }
                    .padding(5)
                    Button("update Counts") {
                        loadStoredCounts()
                        saveStoredCounts()
                        dailyCountsData.sortAndSaveData() //Put code here?
                    }
                    Button("Tap to Load Data") {
                        /* Call the sortAndSaveData() function */
                        dailyCountsData.sortAndSaveData()
                        UserDefaults.standard.set(true, forKey: "Tap") // Set a flag to indicate that data is loaded
                                }
                }
            }
            .sheet(isPresented: $isShowingOverrideField) {
                VStack {
                    TextField("Override Count", text: $overrideCount)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding()
                    
                    Button("Save to UserDefaults") {
                        UserDefaults.standard.set(userDefaultsValue, forKey: "Tap")
                    }
                    Button("Submit") {
                        if let newCount = Int(overrideCount) {
                            tapCount = newCount
                            storeCount(for: currentDate, count: tapCount)
                            dailyCountsData.sortAndSaveData()
                        }
                        isShowingOverrideField.toggle()
                    }
                }
            }
            .alert(isPresented: $showDailyCounts) {
                Alert(
                    title: Text("Tesla Counted: \(tapCount)"),
                    message: dailyCountsMessage(),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadStoredCounts()
            }
        }
        // MARK: code to display the Daily Counts history sorted...
        // MARK: end of last code, but the view is wrong, so I'll have to comment it out and fix it or move it.
    }
    // Define the DailyCount struct
    struct DailyCount: Codable {
        let date: String
        let count: Int
    }
    
    // MARK: Data(DailyCountsData class)
    class DailyCountsData: ObservableObject {
        @Published var dailyCounts: [DailyCount] = [
            DailyCount(date: "2024-04-01", count: 54),
            DailyCount(date: "2024-04-02", count: 58),
            DailyCount(date: "2024-04-03", count: 115),
            DailyCount(date: "2024-04-04", count: 135),
            DailyCount(date: "2024-04-05", count: 143),
            DailyCount(date: "2024-04-06", count: 103),
            DailyCount(date: "2024-04-07", count: 123),
            DailyCount(date: "2024-04-08", count: 133),
            DailyCount(date: "2024-04-09", count: 83),
            DailyCount(date: "2024-04-10", count: 90)]
        
        //MARK: Sorting data then store in UserDefaults
        func sortAndSaveData() {
            dailyCounts.sort { $0.date > $1.date }
            if let encodedData = try? JSONEncoder().encode(dailyCounts) {
                UserDefaults.standard.set(encodedData, forKey: "Tap")
            } } }
    //Whenever you want to save the sorted data (e.g., after sorting or when the data changes), call saveSortedData().
    //To retrieve the sorted data later, you can decode it from UserDefaults using the same key (“SortedDailyCounts”).
    // MARK: - CountListView
    struct CountListView: View {
        @State private var sortDescending = false
        
        private var tapCounts: [Int] {
            _ = Calendar.current.component(.day, from: Date())
            let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 0
            return (1...daysInMonth).map { UserDefaults.standard.integer(forKey: "\($0)") }
        }
        
        var body: some View {
            VStack {
                Toggle("Sort Descending", isOn: $sortDescending)
                    .padding()
                
                List {
                    ForEach(sortDescending ? tapCounts.sorted(by: >) : tapCounts, id: \.self) { day in
                        Text("Day \(day): \(UserDefaults.standard.integer(forKey: String(day))) taps")
                    }
                }
            }
            .navigationTitle("Tap Counts")
        }
    }
    
    // MARK: Sound code
    func playSound(for count: Int) {
        guard isSoundOn else { return }
        let soundName = count % 10 == 0 ? "tada" : "Tesla"
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
    
    //    MARK: AI Example code:
    
    class CountManager {
        private var storedCounts: [String: Int] = [:]
        
        init() {
            // Load existing counts from UserDefaults
            self.loadStoredCounts()
            print("\(storedCounts)")
        }
        
        func updatePrev(previousRecords: [(date: String, count: Int)]) {
            // Check the number of stored dates
            if storedCounts.count < 5 {
                print("Should load previousCounts array because it's less than 5.")
                return
            }
            
            for (date, count) in previousRecords {
                // Check if an entry exists for the current date
                if storedCounts[date] != nil {
                    // Update the existing count
                    storedCounts[date] = count
                    print(count)
                } else {
                    // Add a new entry for the current date
                    storedCounts[date] = count
                    print("UserDefaults (maybe):\(date) ... \(count)")
                }
            }
            
            // Save the updated counts back to UserDefaults
            self.saveCountsToUserDefaults()
        }
        
        private func loadStoredCounts() { //adjusted to "Tap" from "previousCounts"
            if let data = UserDefaults.standard.data(forKey: "Tap"),
               let storedCounts = try? JSONDecoder().decode([String: Int].self, from: data) {
                self.storedCounts = storedCounts
                print("Stored Counts is: \(storedCounts)")
            }
        }
        
        private func saveCountsToUserDefaults() {
            if let data = try? JSONEncoder().encode(storedCounts) {
                UserDefaults.standard.set(data, forKey: "Tap")
            }
        }
    }
    
    // MARK: StoreCount code
    func storeCount(for date: Date, count: Int) {
        storedCounts[date.withoutTime] = count
    }
    
    // MARK: Daily Counts Message
    func dailyCountsMessage() -> Text {
        var message = Text("Counts for date shown:\n")
        
        // Assuming storedCounts is a dictionary with Date keys and count values
        let sortedCounts = storedCounts.sorted { $0.key < $1.key }
        
        for (date, count) in sortedCounts {
            message = message + Text("\(formattedDate(date)): \(count)\n")
        }
        
        return message
    }
    // MARK: function to format the date -- code used to format the date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: Toggle the Sound on : off
    func toggleSound() {
        isSoundOn.toggle()
    }
    
    func loadAndSortCounts() -> [(date: String, count: Int)] {
        if let loadedCounts = try? JSONDecoder().decode([String: Int].self, from: storedCountsData) {
            let sortedCounts = loadedCounts.sorted { $0.key > $1.key }
            return sortedCounts.map { (date: $0.key, count: $0.value) }
        }
        return [] // Return an empty array if decoding fails or no data is available
    }
    
    func loadStoredCounts() {
        if let loadedCounts = try? JSONDecoder().decode([Date: Int].self, from: storedCountsData) {
            storedCounts = loadedCounts
        }
    }
    
    func saveCounts() {
        saveStoredCounts()
        // Add any additional exit logic here
    }
    
    func saveStoredCounts() {
        if let encodedCounts = try? JSONEncoder().encode(storedCounts) {
            storedCountsData = encodedCounts
        }
    }
    
    
    enum SortOrder {
        case ascending, descending
        
        mutating func toggle() {
            self = self == .ascending ? .descending : .ascending
        }
    }
    
    // MARK: Function to format date
    func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
