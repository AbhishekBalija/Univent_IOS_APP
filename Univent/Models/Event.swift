//
//  Event.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let location: String
    let capacity: Int
    let tags: [String]
    let organizerName: String
    let image: String?
    let createdAt: Date
    let updatedAt: Date
    
    var isUpcoming: Bool {
        date > Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EventRegistration: Codable, Identifiable {
    let id: String
    let eventId: String
    let userId: String
    let name: String?
    let email: String?
    let specialRequirements: String?
    let registeredAt: Date
}

struct EventParticipant: Codable, Identifiable {
    let id: String
    let name: String
    let email: String?
    let specialRequirements: String?
    let registeredAt: Date
}