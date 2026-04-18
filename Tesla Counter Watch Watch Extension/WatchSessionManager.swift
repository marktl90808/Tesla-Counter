import Foundation
import WatchConnectivity
import Combine

final class WatchSessionManager: NSObject, ObservableObject {
    static let shared = WatchSessionManager()

    @Published var teslaCount: Int = 0
    @Published var ctCount: Int = 0
    @Published var sessionActive: Bool = false

    private override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Send a simple action message to the phone (e.g., incrementTesla)
    func send(action: String) {
        let message: [String: Any] = ["action": action]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Watch: failed to send message: \(error.localizedDescription)")
            }
        } else {
            // If not reachable, update application context so phone receives when available
            if let safeContext = try? JSONSerialization.data(withJSONObject: ["action": action], options: []) {
                // Not strictly necessary to store data; instead rely on application context for counts
                try? WCSession.default.updateApplicationContext(["request": action])
            } else {
                try? WCSession.default.updateApplicationContext(["request": action])
            }
        }

        // Optimistic local updates for snappy UI
        switch action {
        case "incrementTesla":
            teslaCount += 1
        case "decrementTesla":
            teslaCount = max(0, teslaCount - 1)
        case "incrementCT":
            ctCount += 1
        default:
            break
        }
    }

    /// Request the phone to send the latest counts
    func requestCounts() {
        let message: [String: Any] = ["action": "requestCounts"]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Watch: failed to request counts: \(error.localizedDescription)")
            }
        } else {
            try? WCSession.default.updateApplicationContext(["request": "requestCounts"])
        }
    }
}

extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.sessionActive = activationState == .activated
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let tesla = message["teslaCount"] as? Int {
                self.teslaCount = tesla
            }
            if let ct = message["ctCount"] as? Int {
                self.ctCount = ct
            }
            // Also allow messages that request current counts from the watch
            if let action = message["action"] as? String, action == "requestCounts" {
                // no-op: phone should respond with counts via sendMessage
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let tesla = applicationContext["teslaCount"] as? Int {
                self.teslaCount = tesla
            }
            if let ct = applicationContext["ctCount"] as? Int {
                self.ctCount = ct
            }
        }
    }
}
