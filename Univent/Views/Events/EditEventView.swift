//
//  EditEventView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventService = EventService.shared
    
    let event: Event
    
    @State private var title: String
    @State private var description: String
    @State private var date: Date
    @State private var location: String
    @State private var capacity: Int
    @State private var tags: [String]
    @State private var organizerName: String
    @State private var imageURL: String
    @State private var newTag = ""
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init(event: Event) {
        self.event = event
        self._title = State(initialValue: event.title)
        self._description = State(initialValue: event.description)
        self._date = State(initialValue: event.date)
        self._location = State(initialValue: event.location)
        self._capacity = State(initialValue: event.capacity)
        self._tags = State(initialValue: event.tags)
        self._organizerName = State(initialValue: event.organizerName)
        self._imageURL = State(initialValue: event.image ?? "")
    }
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        capacity > 0
    }
    
    var hasChanges: Bool {
        title != event.title ||
        description != event.description ||
        date != event.date ||
        location != event.location ||
        capacity != event.capacity ||
        tags != event.tags ||
        organizerName != event.organizerName ||
        imageURL != (event.image ?? "")
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
                    TextField("Organizer Name", text: $organizerName)
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
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateEvent()
                    }
                    .disabled(!isFormValid || !hasChanges || isLoading)
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
    
    private func updateEvent() {
        isLoading = true
        
        let finalImageURL = imageURL.isEmpty ? nil : imageURL
        
        eventService.updateEvent(
            id: event.id,
            title: title != event.title ? title : nil,
            description: description != event.description ? description : nil,
            date: date != event.date ? date : nil,
            location: location != event.location ? location : nil,
            capacity: capacity != event.capacity ? capacity : nil,
            tags: tags != event.tags ? tags : nil,
            organizerName: organizerName != event.organizerName ? organizerName : nil,
            image: finalImageURL != event.image ? finalImageURL : nil
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

#Preview {
    EditEventView(event: Event(
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
    ))
}