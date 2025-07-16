//
//  OrganizerDashboardView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct OrganizerDashboardView: View {
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showingCreateEvent = false
    @State private var showingManageEvents = false
    @State private var showingCreateAnnouncement = false
    @State private var myEvents: [Event] = []
    @State private var upcomingEvents: [Event] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Organizer Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Welcome to the organizer dashboard, \(authManager.currentUser?.firstName ?? "Organizer")!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    
                    // Action Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Create Event
                        DashboardCard(
                            title: "Create Event",
                            subtitle: "Create a new event, set up registration, and publish it to participants.",
                            icon: "plus.circle.fill",
                            color: .green,
                            buttonText: "Create New Event"
                        ) {
                            showingCreateEvent = true
                        }
                        
                        // My Events
                        DashboardCard(
                            title: "My Events",
                            subtitle: "View and manage your created events, track registrations, and update details.",
                            icon: "calendar.badge.plus",
                            color: .blue,
                            buttonText: "Manage Events"
                        ) {
                            showingManageEvents = true
                        }
                        
                        // Announcements
                        DashboardCard(
                            title: "Announcements",
                            subtitle: "Create and send announcements to event participants and keep them updated.",
                            icon: "megaphone.fill",
                            color: .orange,
                            buttonText: "Create Announcement"
                        ) {
                            showingCreateAnnouncement = true
                        }
                        
                        // Event Analytics
                        NavigationLink(destination: OrganizerAnalyticsView()) {
                            DashboardCardView(
                                title: "Analytics",
                                subtitle: "View event performance, registration stats, and participant insights.",
                                icon: "chart.bar.fill",
                                color: .purple,
                                buttonText: "View Analytics"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Your Upcoming Events
                    if !upcomingEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Upcoming Events")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            ForEach(upcomingEvents.prefix(3)) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    OrganizerEventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if upcomingEvents.count > 3 {
                                Button("View All Events") {
                                    showingManageEvents = true
                                }
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            }
                        }
                    }
                    
                    // Event Statistics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Event Statistics")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Total Events",
                                value: "\(myEvents.count)",
                                icon: "calendar.circle.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Upcoming",
                                value: "\(upcomingEvents.count)",
                                icon: "clock.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Completed",
                                value: "\(myEvents.filter { !$0.isUpcoming }.count)",
                                icon: "checkmark.circle.fill",
                                color: .mint
                            )
                            
                            StatCard(
                                title: "Total Capacity",
                                value: "\(myEvents.reduce(0) { $0 + $1.capacity })",
                                icon: "person.3.fill",
                                color: .orange
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .refreshable {
                loadOrganizerData()
            }
        }
        .onAppear {
            loadOrganizerData()
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView()
        }
        .sheet(isPresented: $showingManageEvents) {
            OrganizerEventsView()
        }
        .sheet(isPresented: $showingCreateAnnouncement) {
            CreateAnnouncementView()
        }
    }
    
    private func loadOrganizerData() {
        eventService.fetchEvents()
        
        // Filter events created by current organizer
        // In a real app, you'd have an API endpoint to get organizer's events
        myEvents = eventService.events.filter { event in
            event.organizerName == authManager.currentUser?.fullName
        }
        
        upcomingEvents = myEvents.filter { $0.isUpcoming }
    }
}

struct OrganizerEventCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // Event Status Indicator
            Circle()
                .fill(event.isUpcoming ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                        Text(event.location)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(event.shortDate)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(event.isUpcoming ? "Upcoming" : "Completed")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(event.isUpcoming ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(event.isUpcoming ? .green : .gray)
                    .cornerRadius(6)
                
                Button("View details") {
                    // Navigation handled by parent NavigationLink
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    OrganizerDashboardView()
}