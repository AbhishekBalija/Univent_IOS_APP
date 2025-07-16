//
//  AuthManager.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation
import Combine
import Security

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let keychain = KeychainManager()
    private var cancellables = Set<AnyCancellable>()
    
    var token: String? {
        keychain.get(key: "access_token")
    }
    
    private var refreshToken: String? {
        keychain.get(key: "refresh_token")
    }
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let token = token {
            isAuthenticated = true
            getCurrentUser()
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, college: String) -> AnyPublisher<Void, Error> {
        isLoading = true
        
        let body = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password,
            "college": college
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            isLoading = false
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<AuthResponse>(
            service: "auth",
            endpoint: "/auth/register",
            method: .POST,
            body: bodyData,
            requiresAuth: false
        )
        .handleEvents(receiveOutput: { [weak self] response in
            self?.handleAuthSuccess(response)
        }, receiveCompletion: { [weak self] _ in
            self?.isLoading = false
        })
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        isLoading = true
        
        let body = [
            "email": email,
            "password": password
        ]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            isLoading = false
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<AuthResponse>(
            service: "auth",
            endpoint: "/auth/login",
            method: .POST,
            body: bodyData,
            requiresAuth: false
        )
        .handleEvents(receiveOutput: { [weak self] response in
            self?.handleAuthSuccess(response)
        }, receiveCompletion: { [weak self] _ in
            self?.isLoading = false
        })
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    func logout() {
        NetworkManager.shared.request<APIResponse<String>>(
            service: "auth",
            endpoint: "/auth/logout",
            method: .POST
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)
        
        clearAuthData()
    }
    
    func getCurrentUser() {
        NetworkManager.shared.request<APIResponse<User>>(
            service: "auth",
            endpoint: "/auth/me"
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.clearAuthData()
                }
            },
            receiveValue: { [weak self] response in
                if let user = response.user {
                    self?.currentUser = user
                }
            }
        )
        .store(in: &cancellables)
    }
    
    func updateProfile(firstName: String?, lastName: String?, college: String?) -> AnyPublisher<User, Error> {
        var body: [String: Any] = [:]
        if let firstName = firstName { body["firstName"] = firstName }
        if let lastName = lastName { body["lastName"] = lastName }
        if let college = college { body["college"] = college }
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<APIResponse<User>>(
            service: "auth",
            endpoint: "/auth/profile",
            method: .PUT,
            body: bodyData
        )
        .compactMap { response in
            if let user = response.user {
                self.currentUser = user
                return user
            }
            return nil
        }
        .eraseToAnyPublisher()
    }
    
    func forgotPassword(email: String) -> AnyPublisher<String, Error> {
        let body = ["email": email]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return NetworkManager.shared.request<APIResponse<String>>(
            service: "auth",
            endpoint: "/auth/forgot-password",
            method: .POST,
            body: bodyData,
            requiresAuth: false
        )
        .compactMap { $0.message }
        .eraseToAnyPublisher()
    }
    
    private func handleAuthSuccess(_ response: AuthResponse) {
        keychain.set(key: "access_token", value: response.token)
        keychain.set(key: "refresh_token", value: response.refreshToken)
        
        currentUser = response.user
        isAuthenticated = true
    }
    
    private func clearAuthData() {
        keychain.delete(key: "access_token")
        keychain.delete(key: "refresh_token")
        
        currentUser = nil
        isAuthenticated = false
    }
}

class KeychainManager {
    func set(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}