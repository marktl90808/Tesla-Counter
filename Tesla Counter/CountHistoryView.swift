//  CountHistoryView.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 4/24/24.
//
import SwiftUI
import Foundation

struct CountHistoryView: View {
    @ObservedObject var viewModel: TapCountViewModel
    @Environment(\.dismiss) private var dismiss
    init(viewModel: TapCountViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        VStack(spacing: 12) {
            List(viewModel.tapCounts.sorted(by: { $0.date > $1.date })) { count in
                HStack {
                    Text("\(count.date, formatter: dateFormatter):")
                    Spacer()
                    Text(" \(count.t)")
                    Spacer()
                    Text("CT: \(count.ct)")
                }
            }
            .listStyle(.insetGrouped)

            Button(action: { dismiss() }) {
                Text("Back")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .accessibilityIdentifier("HistoryBackButton")
        }
        .navigationTitle("Tesla Count History")
    }
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

