//
//  AdminDashboardView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var adminService = AdminService.shared
    @StateObject private var eventService = EventService.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showingUserManagement = false
    @State private var showingEventManagement = false
    @State private var showingSystemSettings = false
    @State private var totalUsers = 0
    @State private var activeEvents = 0
    @State private var upcomingEvents = 0
    @State private var totalRegistrations = 0
    @State private var systemHealth = "99.8%"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Welcome to the admin dashboard, \(authManager.currentUser?.firstName ?? "Admin")!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    
                    // Management Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // User Management
                        DashboardCard(
                            title: "User Management",
                            subtitle: "Manage users, roles, and permissions across the platform.",
                            icon: "person.2.fill",
                            color: .blue,
                            buttonText: "Manage Users"
                        ) {
                            showingUserManagement = true
                        }
                        
                        // Event Management
                        DashboardCard(
                            title: "Event Management",
                            subtitle: "Review and approve events, manage categories, and monitor event metrics.",
                            icon: "calendar.badge.plus",
                            color: .green,
                            buttonText: "Manage Events"
                        ) {
                            showingEventManagement = true
                        }
                        
                        // System Settings
                        DashboardCard(
                            title: "System Settings",
                            subtitle: "Configure system settings, manage integrations, and monitor platform health.",
                            icon: "gear.badge",
                            color: .gray,
                            buttonText: "System Settings"
                        ) {
                            showingSystemSettings = true
                        }
                        
                        // Announcements
                        NavigationLink(destination: CreateAnnouncementView()) {
                            DashboardCardView(
                                title: "Announcements",
                                subtitle: "Create and manage platform-wide announcements.",
                                icon: "megaphone.fill",
                                color: .orange,
                                buttonText: "Create Announcement"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Platform Analytics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Platform Analytics")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            AnalyticsCard(
                                title: "Total Users",
                                value: "\(totalUsers)",
                                subtitle: "Registered users",
                                icon: "person.fill",
                                color: .blue
                            )
                            
                            AnalyticsCard(
                                title: "Active Events",
                                value: "\(activeEvents)",
                                subtitle: "Events happening today",
                                icon: "calendar.circle.fill",
                                color: .green
                            )
                            
                            AnalyticsCard(
                                title: "Upcoming Events",
                                value: "\(upcomingEvents)",
                                subtitle: "Future scheduled events",
                                icon: "clock.fill",
                                color: .orange
                            )
                            
                            AnalyticsCard(
                                title: "Registrations",
                                value: "\(totalRegistrations)",
                                subtitle: "Total event registrations",
                                icon: "person.badge.plus.fill",
                                color: .purple
                            )
                            
                            AnalyticsCard(
                                title: "System Health",
                                value: systemHealth,
                                subtitle: "Uptime this month",
                                icon: "checkmark.circle.fill",
                                color: .mint
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .refreshable {
                loadDashboardData()
            }
        }
        .onAppear {
            loadDashboardData()
        }
        .sheet(isPresented: $showingUserManagement) {
            UserManagementView()
        }
        .sheet(isPresented: $showingEventManagement) {
            AdminEventManagementView()
        }
        .sheet(isPresented: $showingSystemSettings) {
            SystemSettingsView()
        }
    }
    
    private func loadDashboardData() {
        adminService.fetchAllUsers()
        eventService.fetchEvents()
        
        // Calculate analytics
        totalUsers = adminService.allUsers.count
        activeEvents = eventService.events.filter { event in
            Calendar.current.isDateInToday(event.date)
        }.count
        upcomingEvents = eventService.events.filter { $0.isUpcoming }.count
        totalRegistrations = eventService.events.reduce(0) { $0 + $1.capacity }
    }
}

struct DashboardCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let buttonText: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Button(action: action) {
                Text(buttonText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(color)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(height: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct DashboardCardView: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let buttonText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Text(buttonText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(color)
                .cornerRadius(8)
        }
        .padding()
        .frame(height: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    AdminDashboardView()
}