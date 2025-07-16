//
//  Leaderboard.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation

struct LeaderboardEntry: Codable, Identifiable {
    let id = UUID()
    let userId: String
    let userName: String
    let totalScore: Int?
    let eventCount: Int?
    let score: Int?
    let rank: Int?
    
    var displayScore: Int {
        return totalScore ?? score ?? 0
    }
    
    var rankDisplay: String {
        guard let rank = rank else { return "" }
        switch rank {
        case 1:
            return "🥇"
        case 2:
            return "🥈"
        case 3:
            return "🥉"
        default:
            return "#\(rank)"
        }
    }
}

struct ScoreSubmission: Codable {
    let userId: String
    let score: Int
}