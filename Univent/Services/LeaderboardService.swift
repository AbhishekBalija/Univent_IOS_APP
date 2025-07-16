//
//  LeaderboardService.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation
import Combine

class LeaderboardService: ObservableObject {
    static let shared = LeaderboardService()
    
    @Published var topPerformers: [LeaderboardEntry] = []
    @Published var eventLeaderboard: [LeaderboardEntry] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func fetchTopPerformers(limit: Int = 10) {
        isLoading = true
        
        NetworkManager.shared.request<[LeaderboardEntry]>(
            service: "leaderboard",
            endpoint: "/leaderboard/top?limit=\(limit)",
            requiresAuth: false
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching top performers: \(error)")
                }
            },
            receiveValue: { [weak self] entries in
                self?.topPerformers = entries
            }
        )
        .store(in: &cancellables)
    }
    
    func fetchEventLeaderboard(eventId: String) {
        isLoading = true
        
        NetworkManager.shared.request<[LeaderboardEntry]>(
            service: "leaderboard",
            endpoint: "/leaderboard/event/\(eventId)",
            requiresAuth: false
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching event leaderboard: \(error)")
                }
            },
            receiveValue: { [weak self] entries in
                self?.eventLeaderboard = entries
            }
        )
        .store(in: &cancellables)
    }
    
    func submitScore(eventId: String, userId: String, score: Int) -> AnyPublisher<Void, Error> {
        let body = [
            "userId": userId,
            "score": score
        ] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<APIResponse<LeaderboardEntry>>(
            service: "leaderboard",
            endpoint: "/leaderboard/event/\(eventId)",
            method: .POST,
            body: bodyData
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}