//
//  PhoneConnectivity.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 3/21/2026.
//

import Foundation
import WatchConnectivity

class PhoneConnectivity: NSObject, WCSessionDelegate {
    static let shared = PhoneConnectivity()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}

    // MARK: - Sending Data to Watch
    
    /// Sends today's Tesla and Cybertruck counts to the watch
    func sendCountsToWatch() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let data = UserDefaults.standard.data(forKey: "Tap"),
           let savedCounts = try? JSONDecoder().decode([DailyCount].self, from: data),
           let todayIndex = savedCounts.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            let todayCount = savedCounts[todayIndex]
            let message: [String: Int] = [
                "teslaCount": todayCount.t,
                "ctCount": todayCount.ct
            ]
            
            if WCSession.default.isReachable {
                WCSession.default.sendMessage(message, replyHandler: nil) { error in
                    print("Error sending counts to watch: \(error.localizedDescription)")
                }
            } else {
                // Store for later delivery via application context
                try? WCSession.default.updateApplicationContext(message)
            }
        }
    }
    
    /// Legacy method - kept for compatibility
    func sendCountToWatch(_ count: Int) {
        sendCountsToWatch()
    }

    // MARK: - Receiving Data from Watch
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                switch action {
                case "incrementTesla":
                    TapCountViewModel.shared.incrementCountForToday()
                    print("Watch: Incrementing Tesla count")
                case "incrementCT":
                    TapCountViewModel.shared.incrementCTForToday()
                    print("Watch: Incrementing CT count")
                case "decrementTesla":
                    TapCountViewModel.shared.decrementCountForToday()
                    print("Watch: Decrementing Tesla count")
                default:
                    break
                }
            }
        }
    }
    
    /// Updates watch when counts change on phone
    func updateWatch() {
        DispatchQueue.main.async {
            self.sendCountsToWatch()
        }
    }
}
