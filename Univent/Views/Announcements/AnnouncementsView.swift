//
//  AnnouncementsView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct AnnouncementsView: View {
    @StateObject private var announcementService = AnnouncementService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedPriority: AnnouncementPriority?
    @State private var showingCreateAnnouncement = false
    
    var filteredAnnouncements: [Announcement] {
        if let selectedPriority = selectedPriority {
            return announcementService.announcements.filter { $0.priority == selectedPriority }
        }
        return announcementService.announcements
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Priority Filter
                if !announcementService.announcements.isEmpty {
                    PriorityFilterView(selectedPriority: $selectedPriority)
                        .padding()
                        .background(Color(.systemGroupedBackground))
                }
                
                if announcementService.isLoading {
                    Spacer()
                    ProgressView("Loading announcements...")
                    Spacer()
                } else if filteredAnnouncements.isEmpty {
                    EmptyStateView(
                        image: "megaphone",
                        title: selectedPriority == nil ? "No Announcements" : "No \(selectedPriority!.displayName) Priority Announcements",
                        subtitle: selectedPriority == nil ? "Announcements will appear here when posted" : "Try selecting a different priority filter"
                    )
                } else {
                    List(filteredAnnouncements) { announcement in
                        AnnouncementCardView(announcement: announcement)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Announcements")
            .toolbar {
                if authManager.currentUser?.canCreateEvents == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingCreateAnnouncement = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .refreshable {
                announcementService.fetchAnnouncements()
            }
        }
        .onAppear {
            announcementService.fetchAnnouncements()
        }
        .sheet(isPresented: $showingCreateAnnouncement) {
            CreateAnnouncementView()
        }
    }
}

struct PriorityFilterView: View {
    @Binding var selectedPriority: AnnouncementPriority?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedPriority == nil
                ) {
                    selectedPriority = nil
                }
                
                ForEach(AnnouncementPriority.allCases, id: \.self) { priority in
                    FilterChip(
                        title: priority.displayName,
                        isSelected: selectedPriority == priority
                    ) {
                        selectedPriority = priority
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AnnouncementCardView: View {
    let announcement: Announcement
    @StateObject private var eventService = EventService.shared
    
    var relatedEvent: Event? {
        guard let eventId = announcement.eventId else { return nil }
        return eventService.getEvent(by: eventId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: announcement.priority.systemImage)
                        .font(.caption)
                    Text(announcement.priority.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(announcement.priority.color).opacity(0.2))
                .foregroundColor(Color(announcement.priority.color))
                .cornerRadius(6)
                
                Spacer()
                
                Text(announcement.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(announcement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(announcement.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
            }
            
            // Related Event
            if let event = relatedEvent {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Related to: \(event.title)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AnnouncementsView()
}