//
//  Tesla_CounterApp.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 12/31/2025.
//

import SwiftUI

@main
struct Tesla_CounterApp: App {
    init() {
        _ = PhoneConnectivity.shared
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
