//
//  User.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let college: String
    let role: UserRole
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var isAdmin: Bool {
        role == .admin
    }
    
    var isOrganizer: Bool {
        role == .organizer || role == .admin
    }
    
    var canCreateEvents: Bool {
        role == .organizer || role == .admin
    }
}

enum UserRole: String, Codable, CaseIterable {
    case participant = "participant"
    case organizer = "organizer"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .participant:
            return "Participant"
        case .organizer:
            return "Organizer"
        case .admin:
            return "Admin"
        }
    }
    
    var systemImage: String {
        switch self {
        case .participant:
            return "person.fill"
        case .organizer:
            return "person.2.fill"
        case .admin:
            return "crown.fill"
        }
    }
}