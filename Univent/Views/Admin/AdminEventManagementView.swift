//
//  AdminEventManagementView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct AdminEventManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventService = EventService.shared
    @State private var searchText = ""
    @State private var selectedFilter: AdminEventFilter = .all
    @State private var showingCreateEvent = false
    
    var filteredEvents: [Event] {
        var events = eventService.events
        
        if !searchText.isEmpty {
            events = events.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText) ||
                event.location.localizedCaseInsensitiveContains(searchText) ||
                event.organizerName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case .all:
            return events
        case .upcoming:
            return events.filter { $0.isUpcoming }
        case .past:
            return events.filter { !$0.isUpcoming }
        case .needsApproval:
            // In a real app, you'd have an approval status field
            return events.filter { $0.isUpcoming }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    AdminEventFilterView(selectedFilter: $selectedFilter)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                if eventService.isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    EmptyStateView(
                        image: "calendar.badge.plus",
                        title: "No Events Found",
                        subtitle: searchText.isEmpty ? "No events available" : "No events match your search"
                    )
                } else {
                    List(filteredEvents) { event in
                        NavigationLink(destination: AdminEventDetailView(event: event)) {
                            AdminEventRowView(event: event)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Event Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingCreateEvent = true }) {
                            Label("Create Event", systemImage: "plus")
                        }
                        
                        Button(action: { eventService.fetchEvents() }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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

enum AdminEventFilter: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case past = "Past"
    case needsApproval = "Needs Approval"
}

struct AdminEventFilterView: View {
    @Binding var selectedFilter: AdminEventFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AdminEventFilter.allCases, id: \.self) { filter in
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

struct AdminEventRowView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text("by \(event.organizerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text("\(event.capacity) capacity")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if !event.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(event.tags.prefix(3), id: \.self) { tag in
                            TagView(text: tag)
                        }
                        if event.tags.count > 3 {
                            Text("+\(event.tags.count - 3)")
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

struct AdminEventDetailView: View {
    let event: Event
    @State private var showingEditEvent = false
    @State private var showingParticipants = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            StatusBadge(isUpcoming: event.isUpcoming)
                            Spacer()
                            Text("Created: \(event.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Event Details
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "calendar", title: "Date & Time", value: event.formattedDate)
                        DetailRow(icon: "location", title: "Location", value: event.location)
                        DetailRow(icon: "person.circle", title: "Organizer", value: event.organizerName)
                        DetailRow(icon: "person.2", title: "Capacity", value: "\(event.capacity) participants")
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(event.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Tags
                    if !event.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(event.tags, id: \.self) { tag in
                                    TagView(text: tag)
                                }
                            }
                        }
                    }
                    
                    // Admin Actions
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: { showingEditEvent = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Event")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { showingParticipants = true }) {
                                HStack {
                                    Image(systemName: "person.3")
                                    Text("Participants")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        
                        Button(action: { showingDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Event")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditEvent) {
            EditEventView(event: event)
        }
        .sheet(isPresented: $showingParticipants) {
            EventParticipantsView(eventId: event.id)
        }
        .alert("Delete Event", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle event deletion
            }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
}

#Preview {
    AdminEventManagementView()
}