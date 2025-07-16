//
//  EventParticipantsView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct EventParticipantsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventService = EventService.shared
    
    let eventId: String
    
    @State private var participants: [EventParticipant] = []
    @State private var isLoading = false
    @State private var searchText = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var filteredParticipants: [EventParticipant] {
        if searchText.isEmpty {
            return participants
        }
        
        return participants.filter { participant in
            participant.name.localizedCaseInsensitiveContains(searchText) ||
            (participant.email?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                if !participants.isEmpty {
                    SearchBar(text: $searchText)
                        .padding()
                        .background(Color(.systemGroupedBackground))
                }
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading participants...")
                    Spacer()
                } else if participants.isEmpty {
                    EmptyStateView(
                        image: "person.3",
                        title: "No Participants Yet",
                        subtitle: "Participants will appear here once they register for the event"
                    )
                } else if filteredParticipants.isEmpty {
                    EmptyStateView(
                        image: "magnifyingglass",
                        title: "No Results",
                        subtitle: "No participants match your search"
                    )
                } else {
                    List {
                        Section {
                            ForEach(filteredParticipants) { participant in
                                ParticipantRowView(participant: participant)
                            }
                        } header: {
                            HStack {
                                Text("Participants (\(filteredParticipants.count))")
                                Spacer()
                                Button("Export List") {
                                    exportParticipantList()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Event Participants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadParticipants) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            loadParticipants()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadParticipants() {
        isLoading = true
        
        eventService.getEventParticipants(eventId: eventId)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                },
                receiveValue: { participants in
                    self.participants = participants.sorted { $0.registeredAt > $1.registeredAt }
                }
            )
            .store(in: &cancellables)
    }
    
    private func exportParticipantList() {
        // In a real app, you'd implement CSV export or share functionality
        print("Exporting participant list...")
    }
}

struct ParticipantRowView: View {
    let participant: EventParticipant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Avatar
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(participant.name.prefix(1))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(participant.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    if let email = participant.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Registered \(participant.registeredAt.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)
                    
                    Text("Registered")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            if let requirements = participant.specialRequirements, !requirements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Special Requirements:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(requirements)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EventParticipantsView(eventId: "sample-event-id")
}