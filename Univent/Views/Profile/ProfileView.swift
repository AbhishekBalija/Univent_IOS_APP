//
//  ProfileView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingEditProfile = false
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(initials)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 8) {
                            Text(authManager.currentUser?.fullName ?? "User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            RoleBadge(role: authManager.currentUser?.role ?? .participant)
                        }
                        
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    // Profile Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            ProfileInfoRow(
                                icon: "person.fill",
                                title: "Full Name",
                                value: authManager.currentUser?.fullName ?? "N/A"
                            )
                            
                            ProfileInfoRow(
                                icon: "envelope.fill",
                                title: "Email",
                                value: authManager.currentUser?.email ?? "N/A"
                            )
                            
                            ProfileInfoRow(
                                icon: "building.2.fill",
                                title: "College",
                                value: authManager.currentUser?.college ?? "N/A"
                            )
                            
                            ProfileInfoRow(
                                icon: authManager.currentUser?.role.systemImage ?? "person.fill",
                                title: "Role",
                                value: authManager.currentUser?.role.displayName ?? "N/A"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            if authManager.currentUser?.canCreateEvents == true {
                                NavigationLink(destination: CreateEventView()) {
                                    ProfileActionRow(
                                        icon: "plus.circle.fill",
                                        title: "Create Event",
                                        subtitle: "Organize a new event",
                                        color: .green
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                NavigationLink(destination: CreateAnnouncementView()) {
                                    ProfileActionRow(
                                        icon: "megaphone.fill",
                                        title: "Create Announcement",
                                        subtitle: "Send a new announcement",
                                        color: .orange
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            NavigationLink(destination: EventsView()) {
                                ProfileActionRow(
                                    icon: "calendar.circle.fill",
                                    title: "Browse Events",
                                    subtitle: "Discover upcoming events",
                                    color: .blue
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: LeaderboardView()) {
                                ProfileActionRow(
                                    icon: "trophy.fill",
                                    title: "View Leaderboard",
                                    subtitle: "Check your ranking",
                                    color: .purple
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            Button(action: { showingLogoutConfirmation = true }) {
                                ProfileActionRow(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    title: "Sign Out",
                                    subtitle: "Sign out of your account",
                                    color: .red
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private var initials: String {
        guard let user = authManager.currentUser else { return "U" }
        return String(user.firstName.prefix(1)) + String(user.lastName.prefix(1))
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ProfileActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView()
}