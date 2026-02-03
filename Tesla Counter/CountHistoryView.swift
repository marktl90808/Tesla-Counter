//  CountHistoryView.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 4/24/24.
//
import SwiftUI

struct CountHistoryView: View {
    @ObservedObject var viewModel: TapCountViewModel
    init(viewModel: TapCountViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        List(viewModel.tapCounts.sorted(by: { $0.date > $1.date })) { count in
            HStack {
                Text("\(count.date, formatter: dateFormatter):")
                Spacer()
                Text(" \(count.t)")
            }
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

