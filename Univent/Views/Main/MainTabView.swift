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
                    Image(systemName: "trophy")
                    Text("Leaderboard")
                }
            
            if authManager.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Admin")
                    }
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

#Preview {
    MainTabView()
}