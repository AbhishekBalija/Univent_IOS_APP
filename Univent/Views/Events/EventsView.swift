//
//  EventsView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showingCreateEvent = false
    @State private var searchText = ""
    @State private var selectedFilter: EventFilter = .all
    
    var filteredEvents: [Event] {
        let filtered = eventService.events.filter { event in
            if !searchText.isEmpty {
                return event.title.localizedCaseInsensitiveContains(searchText) ||
                       event.description.localizedCaseInsensitiveContains(searchText) ||
                       event.location.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        
        switch selectedFilter {
        case .all:
            return filtered
        case .upcoming:
            return filtered.filter { $0.isUpcoming }
        case .past:
            return filtered.filter { !$0.isUpcoming }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    FilterSegmentedControl(selection: $selectedFilter)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
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
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                if authManager.currentUser?.canCreateEvents == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingCreateEvent = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .refreshable {
                eventService.fetchEvents()
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

enum EventFilter: String, CaseIterable {
    case all = "All"
    case upcoming = "Upcoming"
    case past = "Past"
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search events...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterSegmentedControl: View {
    @Binding var selection: EventFilter
    
    var body: some View {
        Picker("Filter", selection: $selection) {
            ForEach(EventFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct EmptyStateView: View {
    let image: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: image)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EventsView()
}