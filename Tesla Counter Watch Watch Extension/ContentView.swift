// ContentView.swift
// Tesla Counter - Watch Extension UI

import SwiftUI

struct WatchContentView: View {
    @StateObject private var session = WatchSessionManager.shared

    var body: some View {
        VStack(spacing: 8) {
            Text("Teslas")
                .font(.caption)
                .foregroundColor(.red)
            Text("\(session.teslaCount)")
                .font(.title)
                .foregroundColor(.red)
            HStack {
                Button(action: { session.send(action: "decrementTesla") }) {
                    Image(systemName: "minus.circle.fill")
                }
                Button(action: { session.send(action: "incrementTesla") }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            Divider()
            Text("CT")
                .font(.caption)
                .foregroundColor(.green)
            Text("\(session.ctCount)")
                .font(.title)
                .foregroundColor(.green)
            Button(action: { session.send(action: "incrementCT") }) {
                Image(systemName: "plus.circle.fill")
            }
            Button("Refresh") {
                session.requestCounts()
            }
        }
        .padding()
        .onAppear {
            session.requestCounts()
        }
    }
}

struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
    }
}
