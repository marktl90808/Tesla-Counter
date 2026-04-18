//
//  WatchConnectivityManager.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 4/17/2026.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var teslaCount: Int = 0
    @Published var ctCount: Int = 0
    @Published var isWatchReachable: Bool = false
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Watch session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Watch session deactivated")
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("Watch session activated with state: \(activationState.rawValue)")
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
    
    // MARK: - Message Reception
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            // Update counts if received from iPhone
            if let tesla = message["teslaCount"] as? Int,
               let ct = message["ctCount"] as? Int {
                print("Received counts from iPhone: Tesla=\(tesla), CT=\(ct)")
                self.teslaCount = tesla
                self.ctCount = ct
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async {
            // Handle requests from iPhone
            if let action = message["action"] as? String, action == "requestSync" {
                let reply: [String: Int] = [
                    "teslaCount": self.teslaCount,
                    "ctCount": self.ctCount
                ]
                replyHandler(reply)
                print("Sent count sync reply to iPhone")
            }
        }
    }
    
    // MARK: - Sending Data to iPhone
    
    func sendActionToPhone(_ action: String) {
        let message: [String: String] = ["action": action]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message) { [weak self] replyMessage in
                DispatchQueue.main.async {
                    if let tesla = replyMessage["teslaCount"] as? Int,
                       let ct = replyMessage["ctCount"] as? Int {
                        print("Received count update from iPhone: Tesla=\(tesla), CT=\(ct)")
                        self?.teslaCount = tesla
                        self?.ctCount = ct
                    }
                }
            }
        } else {
            print("Watch is not reachable to phone")
        }
    }
    
    func requestSyncFromPhone() {
        let message: [String: String] = ["action": "requestSync"]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message) { [weak self] replyMessage in
                DispatchQueue.main.async {
                    if let tesla = replyMessage["teslaCount"] as? Int,
                       let ct = replyMessage["ctCount"] as? Int {
                        self?.teslaCount = tesla
                        self?.ctCount = ct
                    }
                }
            }
        }
    }
}
