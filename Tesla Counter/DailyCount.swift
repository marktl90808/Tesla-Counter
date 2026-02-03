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
}
