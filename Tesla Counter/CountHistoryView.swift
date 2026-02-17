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
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(0)

                    Spacer(minLength: 8)

                    Text("\(count.t)")
                        .monospacedDigit()
                        .frame(minWidth: 28, alignment: .trailing)
                        .lineLimit(1)
                        .layoutPriority(1)

                    Spacer(minLength: 8)

                    Text("CT: \(count.ct)")
                        .monospacedDigit()
                        .frame(minWidth: 56, alignment: .trailing)
                        .lineLimit(1)
                        .layoutPriority(1)
                }
            }
            .listStyle(.insetGrouped)

            HStack(spacing: 12) {
                Button(action: { viewModel.resetCTForToday() }) {
                    Text("Reset CT")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("HistoryResetCTButton")

                Button(action: { dismiss() }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("HistoryBackButton")
            }
            .padding(.horizontal)
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

