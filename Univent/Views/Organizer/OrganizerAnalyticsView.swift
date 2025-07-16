//
//  OrganizerAnalyticsView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct OrganizerAnalyticsView: View {
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTimeRange: TimeRange = .month
    
    var myEvents: [Event] {
        eventService.events.filter { event in
            event.organizerName == authManager.currentUser?.fullName
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time Range Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Analytics Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Key Metrics
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    MetricCard(
                        title: "Total Events",
                        value: "\(myEvents.count)",
                        change: "+2 this month",
                        changeType: .positive,
                        icon: "calendar.circle.fill",
                        color: .blue
                    )
                    
                    MetricCard(
                        title: "Total Registrations",
                        value: "\(myEvents.reduce(0) { $0 + $1.capacity })",
                        change: "+15% vs last month",
                        changeType: .positive,
                        icon: "person.3.fill",
                        color: .green
                    )
                    
                    MetricCard(
                        title: "Upcoming Events",
                        value: "\(myEvents.filter { $0.isUpcoming }.count)",
                        change: "3 this week",
                        changeType: .neutral,
                        icon: "clock.fill",
                        color: .orange
                    )
                    
                    MetricCard(
                        title: "Avg. Attendance",
                        value: "85%",
                        change: "+5% vs last month",
                        changeType: .positive,
                        icon: "chart.line.uptrend.xyaxis",
                        color: .purple
                    )
                }
                
                // Event Performance
                VStack(alignment: .leading, spacing: 16) {
                    Text("Event Performance")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if myEvents.isEmpty {
                        EmptyStateView(
                            image: "chart.bar",
                            title: "No Events Yet",
                            subtitle: "Create your first event to see analytics"
                        )
                        .frame(height: 200)
                    } else {
                        ForEach(myEvents.prefix(5)) { event in
                            EventPerformanceRow(event: event)
                        }
                    }
                }
                
                // Popular Tags
                VStack(alignment: .leading, spacing: 16) {
                    Text("Popular Tags")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    let allTags = myEvents.flatMap { $0.tags }
                    let tagCounts = Dictionary(grouping: allTags, by: { $0 })
                        .mapValues { $0.count }
                        .sorted { $0.value > $1.value }
                    
                    if tagCounts.isEmpty {
                        Text("No tags used yet")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        FlowLayout(spacing: 8) {
                            ForEach(Array(tagCounts.prefix(10)), id: \.key) { tag, count in
                                TagWithCount(text: tag, count: count)
                            }
                        }
                    }
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activity")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(myEvents.sorted { $0.createdAt > $1.createdAt }.prefix(5)) { event in
                            ActivityRow(
                                title: "Event Created",
                                subtitle: event.title,
                                time: event.createdAt,
                                icon: "calendar.badge.plus",
                                color: .blue
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            eventService.fetchEvents()
        }
    }
}

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
}

enum ChangeType {
    case positive, negative, neutral
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .secondary
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "arrow.up"
        case .negative: return "arrow.down"
        case .neutral: return "minus"
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let change: String
    let changeType: ChangeType
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: changeType.icon)
                    .font(.caption)
                    .foregroundColor(changeType.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(change)
                    .font(.caption2)
                    .foregroundColor(changeType.color)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct EventPerformanceRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(event.shortDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int.random(in: 50...100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("attendance")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct TagWithCount: View {
    let text: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
            Text("(\(count))")
                .foregroundColor(.secondary)
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(6)
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let time: Date
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(time.formatted(.relative(presentation: .named)))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        OrganizerAnalyticsView()
    }
}