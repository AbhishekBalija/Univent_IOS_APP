//
//  CreateEventView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var location = ""
    @State private var capacity = 50
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var organizerName = ""
    @State private var imageURL = ""
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        capacity > 0 &&
        date > Date()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Date & Time", selection: $date, in: Date()...)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    TextField("Location", text: $location)
                    
                    HStack {
                        Text("Capacity")
                        Spacer()
                        TextField("Capacity", value: $capacity, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Organizer") {
                    TextField("Organizer Name (Optional)", text: $organizerName)
                        .placeholder(when: organizerName.isEmpty) {
                            Text(authManager.currentUser?.fullName ?? "Your Name")
                                .foregroundColor(.secondary)
                        }
                }
                
                Section("Event Image") {
                    TextField("Image URL (Optional)", text: $imageURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $newTag)
                            .onSubmit {
                                addTag()
                            }
                        
                        Button("Add", action: addTag)
                            .disabled(newTag.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagWithRemove(text: tag) {
                                    removeTag(tag)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createEvent()
                    }
                    .disabled(!isFormValid || isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func createEvent() {
        isLoading = true
        
        let finalOrganizerName = organizerName.isEmpty ? authManager.currentUser?.fullName : organizerName
        let finalImageURL = imageURL.isEmpty ? nil : imageURL
        
        eventService.createEvent(
            title: title,
            description: description,
            date: date,
            location: location,
            capacity: capacity,
            tags: tags,
            organizerName: finalOrganizerName,
            image: finalImageURL
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

struct TagWithRemove: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(6)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    CreateEventView()
}