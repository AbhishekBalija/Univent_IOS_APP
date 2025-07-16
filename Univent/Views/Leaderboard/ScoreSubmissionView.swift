//
//  ScoreSubmissionView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct ScoreSubmissionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var leaderboardService = LeaderboardService.shared
    @StateObject private var eventService = EventService.shared
    
    let eventId: String
    
    @State private var participants: [EventParticipant] = []
    @State private var scores: [String: Int] = [:] // userId: score
    @State private var isLoading = false
    @State private var isSubmitting = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    Spacer()
                    ProgressView("Loading participants...")
                    Spacer()
                } else if participants.isEmpty {
                    EmptyStateView(
                        image: "person.3",
                        title: "No Participants",
                        subtitle: "No participants found for this event"
                    )
                } else {
                    List {
                        Section {
                            ForEach(participants) { participant in
                                ScoreInputRow(
                                    participant: participant,
                                    score: Binding(
                                        get: { scores[participant.id] ?? 0 },
                                        set: { scores[participant.id] = $0 }
                                    )
                                )
                            }
                        } header: {
                            Text("Enter scores for each participant")
                        } footer: {
                            Text("Scores will be used to generate the event leaderboard")
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    // Submit Button
                    VStack(spacing: 16) {
                        Button(action: submitScores) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                }
                                Text("Submit All Scores")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasValidScores ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!hasValidScores || isSubmitting)
                        
                        Button("Clear All Scores") {
                            clearAllScores()
                        }
                        .foregroundColor(.red)
                        .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Submit Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
    
    private var hasValidScores: Bool {
        !scores.isEmpty && scores.values.allSatisfy { $0 >= 0 }
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
                    self.participants = participants
                    // Initialize scores with 0
                    for participant in participants {
                        scores[participant.id] = 0
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func submitScores() {
        isSubmitting = true
        
        let submissions = scores.compactMap { (userId, score) -> AnyPublisher<Void, Error>? in
            guard score > 0 else { return nil }
            return leaderboardService.submitScore(eventId: eventId, userId: userId, score: score)
        }
        
        Publishers.MergeMany(submissions)
            .collect()
            .sink(
                receiveCompletion: { completion in
                    isSubmitting = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                },
                receiveValue: { _ in
                    dismiss()
                }
            )
            .store(in: &cancellables)
    }
    
    private func clearAllScores() {
        for participantId in scores.keys {
            scores[participantId] = 0
        }
    }
}

struct ScoreInputRow: View {
    let participant: EventParticipant
    @Binding var score: Int
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            // Participant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(participant.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                if let email = participant.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score Input
            HStack(spacing: 8) {
                Button(action: { if score > 0 { score -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(score > 0 ? .blue : .gray)
                }
                .disabled(score <= 0)
                
                TextField("Score", value: $score, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                
                Button(action: { score += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ScoreSubmissionView(eventId: "sample-event-id")
}