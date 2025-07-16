//
//  AdminView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct AdminView: View {
    @StateObject private var adminService = AdminService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showingUserManagement = false
    @State private var showingSystemSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin Panel")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("System administration and management")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    
                    // Admin Actions
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        AdminActionCard(
                            title: "User Management",
                            subtitle: "Manage users and roles",
                            icon: "person.3.fill",
                            color: .blue
                        ) {
                            showingUserManagement = true
                        }
                        
                        AdminActionCard(
                            title: "System Settings",
                            subtitle: "Configure system settings",
                            icon: "gear.badge",
                            color: .gray
                        ) {
                            showingSystemSettings = true
                        }
                        
                        NavigationLink(destination: AdminEventManagementView()) {
                            AdminActionCardView(
                                title: "Event Management",
                                subtitle: "Manage all events",
                                icon: "calendar.badge.plus",
                                color: .green
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: CreateAnnouncementView()) {
                            AdminActionCardView(
                                title: "Announcements",
                                subtitle: "Create announcements",
                                icon: "megaphone.fill",
                                color: .orange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // System Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("System Overview")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            SystemMetricCard(
                                title: "Total Users",
                                value: "\(adminService.allUsers.count)",
                                icon: "person.3.fill",
                                color: .blue
                            )
                            
                            SystemMetricCard(
                                title: "System Health",
                                value: "99.8%",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            adminService.fetchAllUsers()
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .sheet(isPresented: $showingSystemSettings) {
            SystemSettingsView()
        }
    }
}

struct AdminActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdminActionCardView: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SystemMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(height: 80)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AdminView()
}