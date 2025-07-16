//
//  EventDetailView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct EventDetailView: View {
    let event: Event
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var leaderboardService = LeaderboardService.shared
    @State private var showingRegistration = false
    @State private var showingParticipants = false
    @State private var showingEditEvent = false
    @State private var showingScoreSubmission = false
    @State private var isRegistered = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
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
                .frame(height: 250)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        StatusBadge(isUpcoming: event.isUpcoming)
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
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if event.isUpcoming {
                            if !isRegistered {
                                Button(action: { showingRegistration = true }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Register for Event")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            } else {
                                Button(action: cancelRegistration) {
                                    HStack {
                                        Image(systemName: "person.badge.minus")
                                        Text("Cancel Registration")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        if authManager.currentUser?.canCreateEvents == true {
                            HStack(spacing: 12) {
                                Button(action: { showingParticipants = true }) {
                                    HStack {
                                        Image(systemName: "person.3")
                                        Text("Participants")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.secondary.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: { showingEditEvent = true }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.secondary.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                }
                            }
                            
                            Button(action: { showingScoreSubmission = true }) {
                                HStack {
                                    Image(systemName: "trophy")
                                    Text("Submit Scores")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Event Leaderboard
                    if !leaderboardService.eventLeaderboard.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Event Leaderboard")
                                .font(.headline)
                            
                            ForEach(leaderboardService.eventLeaderboard.prefix(5)) { entry in
                                LeaderboardRowView(entry: entry, showRank: true)
                            }
                            
                            if leaderboardService.eventLeaderboard.count > 5 {
                                NavigationLink("View Full Leaderboard") {
                                    EventLeaderboardView(eventId: event.id)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            leaderboardService.fetchEventLeaderboard(eventId: event.id)
        }
        .sheet(isPresented: $showingRegistration) {
            EventRegistrationView(event: event) { success in
                if success {
                    isRegistered = true
                }
            }
        }
        .sheet(isPresented: $showingParticipants) {
            EventParticipantsView(eventId: event.id)
        }
        .sheet(isPresented: $showingEditEvent) {
            EditEventView(event: event)
        }
        .sheet(isPresented: $showingScoreSubmission) {
            ScoreSubmissionView(eventId: event.id)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func cancelRegistration() {
        eventService.cancelRegistration(eventId: event.id)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                },
                receiveValue: { _ in
                    isRegistered = false
                }
            )
            .store(in: &cancellables)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                    y: bounds.minY + result.frames[index].minY),
                         proposal: ProposedViewSize(result.frames[index].size))
        }
    }
}

struct FlowResult {
    let size: CGSize
    let frames: [CGRect]
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        self.frames = frames
        self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
    }
}

#Preview {
    NavigationView {
        EventDetailView(event: Event(
            id: "1",
            title: "iOS Development Workshop",
            description: "Learn the fundamentals of iOS development with SwiftUI and build your first app. This comprehensive workshop covers everything from basic concepts to advanced techniques.",
            date: Date().addingTimeInterval(86400),
            location: "Computer Lab A",
            capacity: 50,
            tags: ["iOS", "SwiftUI", "Workshop", "Mobile Development"],
            organizerName: "John Doe",
            image: nil,
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}