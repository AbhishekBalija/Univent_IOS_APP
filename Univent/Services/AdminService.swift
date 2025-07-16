//
//  AdminService.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation
import Combine

class AdminService: ObservableObject {
    static let shared = AdminService()
    
    @Published var allUsers: [User] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func fetchAllUsers() {
        guard AuthManager.shared.currentUser?.isAdmin == true else { return }
        
        isLoading = true
        
        NetworkManager.shared.request<[User]>(
            service: "admin",
            endpoint: "/admin/users"
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching users: \(error)")
                }
            },
            receiveValue: { [weak self] users in
                self?.allUsers = users
            }
        )
        .store(in: &cancellables)
    }
    
    func getUserById(id: String) -> AnyPublisher<User, Error> {
        return NetworkManager.shared.request<User>(
            service: "admin",
            endpoint: "/admin/users/\(id)"
        )
    }
    
    func updateUserRole(userId: String, role: UserRole) -> AnyPublisher<User, Error> {
        let body = ["role": role.rawValue]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<User>(
            service: "admin",
            endpoint: "/admin/users/\(userId)/role",
            method: .PUT,
            body: bodyData
        )
        .handleEvents(receiveOutput: { [weak self] updatedUser in
            if let index = self?.allUsers.firstIndex(where: { $0.id == userId }) {
                self?.allUsers[index] = updatedUser
            }
        })
        .eraseToAnyPublisher()
    }
}