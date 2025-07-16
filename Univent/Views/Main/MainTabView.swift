//
//  MainTabView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.currentUser?.isAdmin == true {
                AdminMainView()
            } else if authManager.currentUser?.isOrganizer == true {
                OrganizerMainView()
            } else {
                ParticipantMainView()
            }
        }
    }
}

struct AdminMainView: View {
    var body: some View {
        TabView {
            AdminDashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Dashboard")
                }
            
            EventsView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            
            AnnouncementsView()
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Announcements")
                }
            
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }
            
            AdminView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Admin")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

struct OrganizerMainView: View {
    var body: some View {
        TabView {
            OrganizerDashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Dashboard")
                }
            
            EventsView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            
            AnnouncementsView()
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Announcements")
                }
            
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

struct ParticipantMainView: View {
    var body: some View {
        TabView {
            EventsView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            
            AnnouncementsView()
                .tabItem {
                    Image(systemName: "megaphone")
                    Text("Announcements")
                }
            
            LeaderboardView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Admin")
                    }
            }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}