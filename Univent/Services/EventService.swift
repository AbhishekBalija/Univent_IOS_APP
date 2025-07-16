//
//  EventService.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation
import Combine

class EventService: ObservableObject {
    static let shared = EventService()
    
    @Published var events: [Event] = []
    @Published var registeredEvents: [Event] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func fetchEvents() {
        isLoading = true
        
        NetworkManager.shared.request<[Event]>(
            service: "events",
            endpoint: "/events",
            requiresAuth: false
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching events: \(error)")
                }
            },
            receiveValue: { [weak self] events in
                self?.events = events.sorted { $0.date < $1.date }
            }
        )
        .store(in: &cancellables)
    }
    
    func createEvent(
        title: String,
        description: String,
        date: Date,
        location: String,
        capacity: Int,
        tags: [String],
        organizerName: String?,
        image: String?
    ) -> AnyPublisher<Event, Error> {
        
        var body: [String: Any] = [
            "title": title,
            "description": description,
            "date": ISO8601DateFormatter().string(from: date),
            "location": location,
            "capacity": capacity,
            "tags": tags
        ]
        
        if let organizerName = organizerName {
            body["organizerName"] = organizerName
        }
        
        if let image = image {
            body["image"] = image
        }
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<Event>(
            service: "events",
            endpoint: "/events",
            method: .POST,
            body: bodyData
        )
        .handleEvents(receiveOutput: { [weak self] event in
            self?.events.append(event)
            self?.events.sort { $0.date < $1.date }
        })
        .eraseToAnyPublisher()
    }
    
    func updateEvent(
        id: String,
        title: String?,
        description: String?,
        date: Date?,
        location: String?,
        capacity: Int?,
        tags: [String]?,
        organizerName: String?,
        image: String?
    ) -> AnyPublisher<Event, Error> {
        
        var body: [String: Any] = [:]
        
        if let title = title { body["title"] = title }
        if let description = description { body["description"] = description }
        if let date = date { body["date"] = ISO8601DateFormatter().string(from: date) }
        if let location = location { body["location"] = location }
        if let capacity = capacity { body["capacity"] = capacity }
        if let tags = tags { body["tags"] = tags }
        if let organizerName = organizerName { body["organizerName"] = organizerName }
        if let image = image { body["image"] = image }
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<Event>(
            service: "events",
            endpoint: "/events/\(id)",
            method: .PUT,
            body: bodyData
        )
        .handleEvents(receiveOutput: { [weak self] updatedEvent in
            if let index = self?.events.firstIndex(where: { $0.id == id }) {
                self?.events[index] = updatedEvent
            }
        })
        .eraseToAnyPublisher()
    }
    
    func registerForEvent(
        eventId: String,
        name: String?,
        email: String?,
        specialRequirements: String?
    ) -> AnyPublisher<Void, Error> {
        
        var body: [String: Any] = [:]
        if let name = name { body["name"] = name }
        if let email = email { body["email"] = email }
        if let specialRequirements = specialRequirements { body["specialRequirements"] = specialRequirements }
        
        let bodyData = body.isEmpty ? nil : try? JSONSerialization.data(withJSONObject: body)
        
        return NetworkManager.shared.request<APIResponse<String>>(
            service: "events",
            endpoint: "/events/\(eventId)/register",
            method: .POST,
            body: bodyData
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    func cancelRegistration(eventId: String) -> AnyPublisher<Void, Error> {
        return NetworkManager.shared.request<APIResponse<String>>(
            service: "events",
            endpoint: "/events/\(eventId)/register",
            method: .DELETE
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    func getEventParticipants(eventId: String) -> AnyPublisher<[EventParticipant], Error> {
        return NetworkManager.shared.request<[EventParticipant]>(
            service: "events",
            endpoint: "/events/\(eventId)/participants"
        )
    }
    
    func getEvent(by id: String) -> Event? {
        return events.first { $0.id == id }
    }
}