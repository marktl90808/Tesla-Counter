//  DailyCount.swift
//  Tesla Counter
//
//  Created by Mark Leonard on 4/24/24.
//

import Foundation

public struct DailyCount: Codable, Identifiable {
    public let id: UUID
    let date: Date
    var t: Int
    var ct: Int // New CT count for the day

    public init(id: UUID, date: Date, t: Int, ct: Int = 0) {
        self.id = id
        self.date = date
        self.t = t
        self.ct = ct
    }
}
