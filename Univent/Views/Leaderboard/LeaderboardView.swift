//
//  LeaderboardView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var leaderboardService = LeaderboardService.shared
    @State private var selectedTab: LeaderboardTab = .global
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Leaderboard Type", selection: $selectedTab) {
                    ForEach(LeaderboardTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Content
                switch selectedTab {
                case .global:
                    GlobalLeaderboardView()
                case .events:
                    EventLeaderboardsView()
                }
            }
            .navigationTitle("Leaderboard")
        }
        .onAppear {
            leaderboardService.fetchTopPerformers()
        }
    }
}

enum LeaderboardTab: String, CaseIterable {
    case global = "Global"
    case events = "Events"
}

struct GlobalLeaderboardView: View {
    @StateObject private var leaderboardService = LeaderboardService.shared
    
    var body: some View {
        Group {
            if leaderboardService.isLoading {
                Spacer()
                ProgressView("Loading leaderboard...")
                Spacer()
            } else if leaderboardService.topPerformers.isEmpty {
                EmptyStateView(
                    image: "trophy",
                    title: "No Rankings Yet",
                    subtitle: "Participate in events to appear on the leaderboard"
                )
            } else {
                List {
                    Section {
                        ForEach(Array(leaderboardService.topPerformers.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRowView(
                                entry: LeaderboardEntry(
                                    userId: entry.userId,
                                    userName: entry.userName,
                                    totalScore: entry.totalScore,
                                    eventCount: entry.eventCount,
                                    score: nil,
                                    rank: index + 1
                                ),
                                showRank: true
                            )
                        }
                    } header: {
                        Text("Top Performers")
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .refreshable {
            leaderboardService.fetchTopPerformers()
        }
    }
}

struct EventLeaderboardsView: View {
    @StateObject private var eventService = EventService.shared
    
    var pastEvents: [Event] {
        eventService.events.filter { !$0.isUpcoming }
    }
    
    var body: some View {
        Group {
            if pastEvents.isEmpty {
                EmptyStateView(
                    image: "calendar.badge.clock",
                    title: "No Past Events",
                    subtitle: "Event leaderboards will appear here after events are completed"
                )
            } else {
                List(pastEvents) { event in
                    NavigationLink(destination: EventLeaderboardView(eventId: event.id)) {
                        EventLeaderboardRowView(event: event)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            eventService.fetchEvents()
        }
    }
}

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let showRank: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            if showRank {
                Text(entry.rankDisplay)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
                    .frame(width: 40)
            }
            
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(entry.userName.prefix(1))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.userName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                if let eventCount = entry.eventCount {
                    Text("\(eventCount) events participated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.displayScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var rankColor: Color {
        guard let rank = entry.rank else { return .primary }
        
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }
}

struct EventLeaderboardRowView: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
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
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    )
            }
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(8)
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(event.shortDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(event.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct EventLeaderboardView: View {
    let eventId: String
    @StateObject private var leaderboardService = LeaderboardService.shared
    @StateObject private var eventService = EventService.shared
    
    var event: Event? {
        eventService.getEvent(by: eventId)
    }
    
    var body: some View {
        Group {
            if leaderboardService.isLoading {
                ProgressView("Loading leaderboard...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if leaderboardService.eventLeaderboard.isEmpty {
                EmptyStateView(
                    image: "trophy",
                    title: "No Scores Yet",
                    subtitle: "Scores will appear here once the event organizer submits them"
                )
            } else {
                List {
                    Section {
                        ForEach(leaderboardService.eventLeaderboard) { entry in
                            LeaderboardRowView(entry: entry, showRank: true)
                        }
                    } header: {
                        if let event = event {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("\(event.formattedDate) • \(event.location)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Event Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            leaderboardService.fetchEventLeaderboard(eventId: eventId)
        }
    }
}

#Preview {
    LeaderboardView()
}