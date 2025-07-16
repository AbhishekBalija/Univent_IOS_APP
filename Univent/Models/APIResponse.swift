//
//  APIResponse.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let user: User?
    let token: String?
    let refreshToken: String?
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let user: User
    let token: String
    let refreshToken: String
}

struct TokenRefreshResponse: Codable {
    let success: Bool
    let token: String
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
    let error: String?
}