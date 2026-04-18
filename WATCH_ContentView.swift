//
//  ContentView.swift
//  Tesla Counter Watch App
//
//  Created by Mark Leonard on 4/17/2026.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var connectivity = WatchConnectivityManager.shared
    @State private var teslaCount: Int = 0
    @State private var ctCount: Int = 0
    @State private var lastUpdate: Date = Date()
    
    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text("Tesla Counter")
                .font(.headline)
                .lineLimit(1)
            
            Divider()
            
            // Tesla Count Display and Buttons
            VStack(spacing: 4) {
                Text("Teslas")
                    .font(.caption2)
                    .foregroundColor(.red)
                
                Text("\(teslaCount)")
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(.red)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Button(action: decrementTesla) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: incrementTesla) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // Cybertruck Count Display and Button
            VStack(spacing: 4) {
                Text("Cybertrucks")
                    .font(.caption2)
                    .foregroundColor(.green)
                
                Text("\(ctCount)")
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(.green)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Button(action: incrementCT) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // Sync Status
            Text(connectivity.isWatchReachable ? "Connected" : "Syncing...")
                .font(.caption)
                .foregroundColor(connectivity.isWatchReachable ? .green : .yellow)
        }
        .padding(8)
        .onAppear {
            requestSync()
        }
        .onReceive(Timer.publish(every: 5).autoconnect()) { _ in
            requestSync()
        }
    }
    
    // MARK: - Actions
    
    func incrementTesla() {
        teslaCount += 1
        connectivity.sendActionToPhone("incrementTesla")
    }
    
    func decrementTesla() {
        if teslaCount > 0 {
            teslaCount -= 1
        }
        connectivity.sendActionToPhone("decrementTesla")
    }
    
    func incrementCT() {
        ctCount += 1
        connectivity.sendActionToPhone("incrementCT")
    }
    
    func requestSync() {
        connectivity.requestSyncFromPhone()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
