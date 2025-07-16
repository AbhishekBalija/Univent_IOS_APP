//
//  Announcement.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation

struct Announcement: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let eventId: String?
    let priority: AnnouncementPriority
    let isPublished: Bool
    let createdAt: Date
    let updatedAt: Date
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

enum AnnouncementPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
    
    var systemImage: String {
        switch self {
        case .low:
            return "info.circle"
        case .medium:
            return "exclamationmark.triangle"
        case .high:
            return "exclamationmark.octagon"
        }
    }
}