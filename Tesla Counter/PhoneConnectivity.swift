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

    func sendCountToWatch(_ count: Int) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["count": count], replyHandler: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let newCount = message["count"] as? Int {
            DispatchQueue.main.async {
                // ⭐ FIXED LINE
                TapCountViewModel.shared.updateCountFromWatch(newCount)
            }
        }
    }
}
