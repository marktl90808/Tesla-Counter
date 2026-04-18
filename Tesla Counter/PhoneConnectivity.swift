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
                 error: Error?) {
        // Log activation details and notify UI
        print("WCSession activated: state=\(activationState.rawValue), paired=\(session.isPaired), watchAppInstalled=\(session.isWatchAppInstalled), reachable=\(session.isReachable)")
        NotificationCenter.default.post(name: .phoneConnectivityDidUpdate, object: nil, userInfo: ["isPaired": session.isPaired, "isWatchAppInstalled": session.isWatchAppInstalled, "isReachable": session.isReachable])
    }

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
    
    /// Extracted to make message processing testable and reusable
    func processIncomingMessage(_ message: [String: Any]) {
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
            case "requestCounts":
                // Watch is asking for the latest counts
                updateWatch()
            default:
                break
            }
            return
        }

        // If the message contains absolute counts, update directly
        if let teslaCount = message["teslaCount"] as? Int {
            TapCountViewModel.shared.updateCountFromWatch(teslaCount)
            print("Watch: Set Tesla count to \(teslaCount)")
        }
        if let ctCount = message["ctCount"] as? Int {
            TapCountViewModel.shared.updateCTFromWatch(ctCount)
            print("Watch: Set CT count to \(ctCount)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.processIncomingMessage(message)
        }
    }
    
    /// Updates watch when counts change on phone
    func updateWatch() {
        DispatchQueue.main.async {
            self.sendCountsToWatch()
        }
    }
}

extension Notification.Name {
    static let phoneConnectivityDidUpdate = Notification.Name("phoneConnectivityDidUpdate")
}
