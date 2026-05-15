import Foundation
import WatchConnectivity
import Combine

// Lightweight WatchConnectivity manager for the Watch extension.
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    @Published var teslaCount: Int = 0
    @Published var ctCount: Int = 0

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // Send an action message to the phone
    func sendActionToPhone(_ action: String) {
        guard WCSession.default.isPaired, WCSession.default.isReachable else { return }
        let message: [String: Any] = ["action": action]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Watch sendMessage error: \(error.localizedDescription)")
        }
    }

    // Receive messages from phone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let t = message["teslaCount"] as? Int {
                self.teslaCount = t
            }
            if let ct = message["ctCount"] as? Int {
                self.ctCount = ct
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activated: \(activationState)")
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}
