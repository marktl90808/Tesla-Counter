//  TapCountViewModel.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 4/24/24.
//

import Foundation
import WatchConnectivity

class TapCountViewModel: ObservableObject {
    static let shared = TapCountViewModel()

    @Published var tapCounts: [DailyCount] = []
    @Published var t: Int = UserDefaults.standard.integer(forKey: "Tap")
    @Published var ct: Int = 0
    var userDefaultsKey = "Tap"
    
    func updateCountForDate(_ date: Date, count: Int) {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           var existingCounts = try? JSONDecoder().decode([Date: Int].self, from: data) {
            existingCounts[date] = count
            
            if let encodedCounts = try? JSONEncoder().encode(existingCounts) {
                UserDefaults.standard.set(encodedCounts, forKey: userDefaultsKey)
            }
        }
    }

    @Published var showAlert: Bool = false
    
    var playSound: ((String) -> Void)?
    
    init() {
        loadCounts()
        print("Loaded tapCount from UserDefaults:", t)
    }
    
    func loadCounts() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let savedCounts = try? JSONDecoder().decode([DailyCount].self, from: data) {
                tapCounts = savedCounts

                let today = Calendar.current.startOfDay(for: Date())
                if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
                    t = tapCounts[todayIndex].t
                    ct = tapCounts[todayIndex].ct
                } else {
                    t = 0
                    ct = 0
                }
            }
        }
    }
    
    func saveCounts() {
        if let encoded = try? JSONEncoder().encode(tapCounts) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func incrementCountForToday() {
        let today = Calendar.current.startOfDay(for: Date())
        if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            tapCounts[todayIndex].t += 1
            t = tapCounts[todayIndex].t // Update t to reflect today's count only
        } else {
            let newCount = DailyCount(id: UUID(), date: today, t: 1, ct: 0)
            tapCounts.append(newCount)
            t = 1 // Set t to 1 as this is the first count for today
        }
        
        saveCounts()
        print("Updated tapCount after incrementing:", t)
        print("TapCounts saved to UserDefaults after incrementing:", tapCounts)
        
        // NEW Send updated counts to watch.
        
        PhoneConnectivity.shared.sendCountToWatch(t)

    }
    
    func incrementCTForToday() {
        let today = Calendar.current.startOfDay(for: Date())
        if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            tapCounts[todayIndex].ct += 1
            ct = tapCounts[todayIndex].ct
        } else {
            let newCount = DailyCount(id: UUID(), date: today, t: 0, ct: 1)
            tapCounts.append(newCount)
            ct = 1
        }
        saveCounts()
    }

    func updateCountFromWatch(_ newCount: Int) {
        let today = Calendar.current.startOfDay(for: Date())

        if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            tapCounts[todayIndex].t = newCount
        } else {
            let newDaily = DailyCount(id: UUID(), date: today, t: newCount, ct: 0)
            tapCounts.append(newDaily)
        }

        t = newCount
        saveCounts()
    }


    func resetCountForToday() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            tapCounts[todayIndex].t = 0
            t = 0 // Reset t to 0 as today's count is reset
            saveCounts()
            print("Resetting tapCounts[todayIndex].t to: \(tapCounts[todayIndex].t)")
        }
    }
    
    func resetCTForToday() {
        let today = Calendar.current.startOfDay(for: Date())
        if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            tapCounts[todayIndex].ct = 0
            ct = 0
            saveCounts()
        }
    }

    func enterNewCount(dateString: String, countInput: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else {
            print("Invalid date format")
            return
        }
        
       if let existingIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            tapCounts[existingIndex].t = countInput
        } else {
           let newCount = DailyCount(id: UUID(), date: date, t: countInput, ct: 0)
            tapCounts.append(newCount)
        }
        
        if Calendar.current.isDate(date, inSameDayAs: Date()) {
            t = countInput
        }
        saveCounts()
        
        showAlert = true
    }

    func decrementCountForToday() {
       if t > 0 {
            t -= 1
              if let todayIndex = tapCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                tapCounts[todayIndex].t -= 1
                saveCounts()
            }
        }
    }

}
