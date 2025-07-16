//
//  AnnouncementService.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation
import Combine

class AnnouncementService: ObservableObject {
    static let shared = AnnouncementService()
    
    @Published var announcements: [Announcement] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func fetchAnnouncements(eventId: String? = nil, priority: AnnouncementPriority? = nil) {
        isLoading = true
        
        var endpoint = "/announcements"
        var queryParams: [String] = []
        
        if let eventId = eventId {
            queryParams.append("eventId=\(eventId)")
        }
        
        if let priority = priority {
            queryParams.append("priority=\(priority.rawValue)")
        }
        
        queryParams.append("isPublished=true")
        
        if !queryParams.isEmpty {
            endpoint += "?" + queryParams.joined(separator: "&")
        }
        
        NetworkManager.shared.request<[Announcement]>(
            service: "announcements",
            endpoint: endpoint,
            requiresAuth: false
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching announcements: \(error)")
                }
            },
            receiveValue: { [weak self] announcements in
                self?.announcements = announcements.sorted { $0.createdAt > $1.createdAt }
            }
        )
        .store(in: &cancellables)
    }
    
    func createAnnouncement(
        title: String,
        content: String,
        eventId: String? = nil,
        priority: AnnouncementPriority = .medium,
        isPublished: Bool = true
    ) -> AnyPublisher<Announcement, Error> {
        
        var body: [String: Any] = [
            "title": title,
            "content": content,
            "priority": priority.rawValue,
            "isPublished": isPublished
        ]
        
        if let eventId = eventId {
            body["eventId"] = eventId
        }
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<Announcement>(
            service: "announcements",
            endpoint: "/announcements",
            method: .POST,
            body: bodyData
        )
        .handleEvents(receiveOutput: { [weak self] announcement in
            self?.announcements.insert(announcement, at: 0)
        })
        .eraseToAnyPublisher()
    }
    
    func updateAnnouncement(
        id: String,
        title: String?,
        content: String?,
        priority: AnnouncementPriority?,
        isPublished: Bool?
    ) -> AnyPublisher<Announcement, Error> {
        
        var body: [String: Any] = [:]
        
        if let title = title { body["title"] = title }
        if let content = content { body["content"] = content }
        if let priority = priority { body["priority"] = priority.rawValue }
        if let isPublished = isPublished { body["isPublished"] = isPublished }
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<Announcement>(
            service: "announcements",
            endpoint: "/announcements/\(id)",
            method: .PUT,
            body: bodyData
        )
        .handleEvents(receiveOutput: { [weak self] updatedAnnouncement in
            if let index = self?.announcements.firstIndex(where: { $0.id == id }) {
                self?.announcements[index] = updatedAnnouncement
            }
        })
        .eraseToAnyPublisher()
    }
    
    func deleteAnnouncement(id: String) -> AnyPublisher<Void, Error> {
        return NetworkManager.shared.request<APIResponse<String>>(
            service: "announcements",
            endpoint: "/announcements/\(id)",
            method: .DELETE
        )
        .handleEvents(receiveOutput: { [weak self] _ in
            self?.announcements.removeAll { $0.id == id }
        })
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}