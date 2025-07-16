//
//  EventRegistrationView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct EventRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    
    let event: Event
    let onRegistrationComplete: (Bool) -> Void
    
    @State private var name: String
    @State private var email: String
    @State private var specialRequirements = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init(event: Event, onRegistrationComplete: @escaping (Bool) -> Void) {
        self.event = event
        self.onRegistrationComplete = onRegistrationComplete
        
        // Pre-fill with user data if available
        let currentUser = AuthManager.shared.currentUser
        self._name = State(initialValue: currentUser?.fullName ?? "")
        self._email = State(initialValue: currentUser?.email ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Event Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Register for Event")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                    Text(event.formattedDate)
                                        .font(.caption)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "location")
                                        .font(.caption)
                                    Text(event.location)
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Registration Form
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Information")
                                .font(.headline)
                            
                            Text("This information will be shared with the event organizer.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter your full name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email Address")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Special Requirements (Optional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Any dietary restrictions, accessibility needs, etc.", text: $specialRequirements, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...5)
                            }
                        }
                    }
                    
                    // Terms and Conditions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Registration Terms")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint(text: "Registration is free and open to all college students")
                            BulletPoint(text: "You will receive confirmation and updates via email")
                            BulletPoint(text: "Please arrive 15 minutes before the event starts")
                            BulletPoint(text: "Cancellation is allowed up to 24 hours before the event")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Register Button
                    Button(action: registerForEvent) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text("Register for Event")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@")
    }
    
    private func registerForEvent() {
        isLoading = true
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRequirements = specialRequirements.trimmingCharacters(in: .whitespacesAndNewlines)
        
        eventService.registerForEvent(
            eventId: event.id,
            name: trimmedName.isEmpty ? nil : trimmedName,
            email: trimmedEmail.isEmpty ? nil : trimmedEmail,
            specialRequirements: trimmedRequirements.isEmpty ? nil : trimmedRequirements
        )
        .sink(
            receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                    showingError = true
                    onRegistrationComplete(false)
                }
            },
            receiveValue: { _ in
                onRegistrationComplete(true)
                dismiss()
            }
        )
        .store(in: &cancellables)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .fontWeight(.bold)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    EventRegistrationView(
        event: Event(
            id: "1",
            title: "iOS Development Workshop",
            description: "Learn the fundamentals of iOS development with SwiftUI and build your first app.",
            date: Date().addingTimeInterval(86400),
            location: "Computer Lab A",
            capacity: 50,
            tags: ["iOS", "SwiftUI", "Workshop"],
            organizerName: "John Doe",
            image: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    ) { success in
        print("Registration completed: \(success)")
    }
}