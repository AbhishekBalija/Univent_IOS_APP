//
//  CreateAnnouncementView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct CreateAnnouncementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var announcementService = AnnouncementService.shared
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedEvent: Event?
    @State private var priority: AnnouncementPriority = .medium
    @State private var isPublished = true
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var availableEvents: [Event] {
        if authManager.currentUser?.isAdmin == true {
            return eventService.events
        } else {
            // Organizers can only create announcements for their events
            return eventService.events.filter { event in
                event.organizerName == authManager.currentUser?.fullName
            }
        }
    }
    
    var isFormValid: Bool {
        !title.isEmpty && !content.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Announcement Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Settings") {
                    Picker("Priority", selection: $priority) {
                        ForEach(AnnouncementPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.systemImage)
                                    .foregroundColor(Color(priority.color))
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    
                    Toggle("Publish Immediately", isOn: $isPublished)
                }
                
                Section("Target Audience") {
                    Picker("Event (Optional)", selection: $selectedEvent) {
                        Text("All Users")
                            .tag(nil as Event?)
                        
                        ForEach(availableEvents) { event in
                            Text(event.title)
                                .tag(event as Event?)
                        }
                    }
                    
                    if selectedEvent == nil {
                        Text("This announcement will be visible to all users")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("This announcement will be visible to participants of the selected event")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Preview") {
                    AnnouncementPreview(
                        title: title.isEmpty ? "Announcement Title" : title,
                        content: content.isEmpty ? "Announcement content will appear here..." : content,
                        priority: priority,
                        eventTitle: selectedEvent?.title
                    )
                }
            }
            .navigationTitle("Create Announcement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isPublished ? "Publish" : "Save Draft") {
                        createAnnouncement()
                    }
                    .disabled(!isFormValid || isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            eventService.fetchEvents()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createAnnouncement() {
        isLoading = true
        
        announcementService.createAnnouncement(
            title: title,
            content: content,
            eventId: selectedEvent?.id,
            priority: priority,
            isPublished: isPublished
        )
        .sink(
            receiveCompletion: { completion in
                isLoading = false
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
}

struct AnnouncementPreview: View {
    let title: String
    let content: String
    let priority: AnnouncementPriority
    let eventTitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: priority.systemImage)
                        .font(.caption)
                    Text(priority.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(priority.color).opacity(0.2))
                .foregroundColor(Color(priority.color))
                .cornerRadius(6)
                
                Spacer()
                
                Text("now")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(4)
            
            if let eventTitle = eventTitle {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("Event: \(eventTitle)")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    CreateAnnouncementView()
}