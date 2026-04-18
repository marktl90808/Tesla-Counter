// ExtensionDelegate.swift
// Tesla Counter - Watch Extension helper

import WatchKit

// Minimal extension delegate that the WatchKit Extension target can use.
// This file intentionally does not define an @main App. It should be added
// to the WatchKit Extension target (not the WatchKit App target).

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused when the application was inactive.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state.
    }
}
