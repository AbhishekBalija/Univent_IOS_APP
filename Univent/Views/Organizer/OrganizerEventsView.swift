//
//  OrganizerEventsView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct OrganizerEventsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var searchText = ""
    @State private var selectedFilter: OrganizerEventFilter = .all
    @State private var showingCreateEvent = false
    
    var myEvents: [Event] {
        // Filter events created by current organizer
        eventService.events.filter { event in
            event.organizerName == authManager.currentUser?.fullName
        }
    }
    
    var filteredEvents: [Event] {
        var events = myEvents
        
        if !searchText.isEmpty {
            events = events.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText) ||
                event.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case .all:
            return events
        case .upcoming:
            return events.filter { $0.isUpcoming }
        case .past:
            return events.filter { !$0.isUpcoming }
        case .draft:
            // In a real app, you'd have a draft status
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    OrganizerEventFilterView(selectedFilter: $selectedFilter)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                if eventService.isLoading {
                    Spacer()
                    ProgressView("Loading your events...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    EmptyStateView(
                        image: "calendar.badge.plus",
                        title: searchText.isEmpty ? "No Events Created" : "No Events Found",
                        subtitle: searchText.isEmpty ? "Create your first event to get started" : "No events match your search"
                    )
                } else {
                    List(filteredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            OrganizerEventListCard(event: event)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            eventService.fetchEvents()
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView()
        }
    }
}

enum OrganizerEventFilter: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case past = "Past"
    case draft = "Draft"
}

struct OrganizerEventFilterView: View {
    @Binding var selectedFilter: OrganizerEventFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(OrganizerEventFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct OrganizerEventListCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(isUpcoming: event.isUpcoming)
                    
                    Text(event.shortDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
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
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text("\(event.capacity)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            if !event.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(event.tags.prefix(4), id: \.self) { tag in
                            TagView(text: tag)
                        }
                        if event.tags.count > 4 {
                            Text("+\(event.tags.count - 4)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OrganizerEventsView()
}