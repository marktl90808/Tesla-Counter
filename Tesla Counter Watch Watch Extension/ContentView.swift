// ContentView.swift
// Tesla Counter - Watch Extension UI

import SwiftUI

struct WatchContentView: View {
    @State private var teslaCount: Int = 0
    @State private var ctCount: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("Teslas")
                .font(.caption)
                .foregroundColor(.red)
            Text("\(teslaCount)")
                .font(.title)
                .foregroundColor(.red)
            HStack {
                Button(action: { teslaCount = max(0, teslaCount - 1) }) {
                    Image(systemName: "minus.circle.fill")
                }
                Button(action: { teslaCount += 1 }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            Divider()
            Text("CT")
                .font(.caption)
                .foregroundColor(.green)
            Text("\(ctCount)")
                .font(.title)
                .foregroundColor(.green)
            Button(action: { ctCount += 1 }) {
                Image(systemName: "plus.circle.fill")
            }
        }
        .padding()
    }
}

struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
    }
}
