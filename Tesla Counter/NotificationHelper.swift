import Foundation
import UserNotifications

/// Simple helper to register notification categories and schedule a local test notification
final class NotificationHelper {
    static let shared = NotificationHelper()
    private init() {}

    let testCategoryIdentifier = "teslaNotification"

    func registerCategories() {
        let action = UNNotificationAction(identifier: "openApp", title: "Open", options: [.foreground])
        let category = UNNotificationCategory(identifier: testCategoryIdentifier, actions: [action], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion?(granted)
            }
        }
    }

    func scheduleTestNotification(after seconds: TimeInterval = 5) {
        requestAuthorizationIfNeeded { granted in
            guard granted else { return }
            self.registerCategories()

            let content = UNMutableNotificationContent()
            content.title = "Tesla Counter"
            content.body = "Test notification from iPhone — category teslaNotification"
            content.categoryIdentifier = self.testCategoryIdentifier

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            let request = UNNotificationRequest(identifier: "tesla_test_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule test notification: \(error)")
                } else {
                    print("Test notification scheduled in \(seconds) seconds")
                }
            }
        }
    }
}
