//
//  EventCardView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image
            AsyncImage(url: URL(string: event.image ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                    )
            }
            .frame(height: 160)
            .clipped()
            
            // Event Content
            VStack(alignment: .leading, spacing: 12) {
                // Date and Status
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(event.shortDate)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    StatusBadge(isUpcoming: event.isUpcoming)
                }
                
                // Title
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Description
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Location and Time
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                        Text(event.location)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(event.timeString)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Tags
                if !event.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(event.tags, id: \.self) { tag in
                                TagView(text: tag)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                // Organizer
                HStack {
                    Image(systemName: "person.circle")
                        .font(.caption)
                    Text("by \(event.organizerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .font(.caption)
                        Text("\(event.capacity) spots")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let isUpcoming: Bool
    
    var body: some View {
        Text(isUpcoming ? "Upcoming" : "Past")
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isUpcoming ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundColor(isUpcoming ? .green : .gray)
            .cornerRadius(6)
    }
}

struct TagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(6)
    }
}

#Preview {
    EventCardView(event: Event(
        id: "1",
        title: "iOS Development Workshop",
        description: "Learn the fundamentals of iOS development with SwiftUI and build your first app.",
        date: Date().addingTimeInterval(86400),
        location: "Computer Lab A",
        capacity: 50,
        tags: ["iOS", "SwiftUI", "Workshop"],
        organizerName: "John Doe",
        image: nil,
        createdAt: Date(),
        updatedAt: Date()
    ))
    .padding()
}