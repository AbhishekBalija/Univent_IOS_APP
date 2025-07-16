//
//  UserManagementView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct UserManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adminService = AdminService.shared
    @State private var searchText = ""
    @State private var selectedRole: UserRole? = nil
    @State private var showingRoleUpdate = false
    @State private var selectedUser: User?
    @State private var cancellables = Set<AnyCancellable>()
    
    var filteredUsers: [User] {
        var users = adminService.allUsers
        
        if !searchText.isEmpty {
            users = users.filter { user in
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText) ||
                user.college.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedRole = selectedRole {
            users = users.filter { $0.role == selectedRole }
        }
        
        return users
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText)
                    
                    RoleFilterView(selectedRole: $selectedRole)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                if adminService.isLoading {
                    Spacer()
                    ProgressView("Loading users...")
                    Spacer()
                } else if filteredUsers.isEmpty {
                    EmptyStateView(
                        image: "person.3",
                        title: "No Users Found",
                        subtitle: searchText.isEmpty ? "No users available" : "No users match your search"
                    )
                } else {
                    List(filteredUsers) { user in
                        UserRowView(user: user) {
                            selectedUser = user
                            showingRoleUpdate = true
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("User Management")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        adminService.fetchAllUsers()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            adminService.fetchAllUsers()
        }
        .sheet(isPresented: $showingRoleUpdate) {
            if let user = selectedUser {
                RoleUpdateView(user: user) { updatedUser in
                    // Handle role update success
                }
            }
        }
    }
}

struct UserRowView: View {
    let user: User
    let onRoleUpdate: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(user.college)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                RoleBadge(role: user.role)
                
                Button("Change Role") {
                    onRoleUpdate()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

struct RoleBadge: View {
    let role: UserRole
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: role.systemImage)
                .font(.caption2)
            Text(role.displayName)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(roleColor.opacity(0.2))
        .foregroundColor(roleColor)
        .cornerRadius(6)
    }
    
    private var roleColor: Color {
        switch role {
        case .admin:
            return .red
        case .organizer:
            return .orange
        case .participant:
            return .blue
        }
    }
}

struct RoleFilterView: View {
    @Binding var selectedRole: UserRole?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedRole == nil
                ) {
                    selectedRole = nil
                }
                
                ForEach(UserRole.allCases, id: \.self) { role in
                    FilterChip(
                        title: role.displayName,
                        isSelected: selectedRole == role
                    ) {
                        selectedRole = role
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct RoleUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User
    let onUpdate: (User) -> Void
    @State private var selectedRole: UserRole
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init(user: User, onUpdate: @escaping (User) -> Void) {
        self.user = user
        self.onUpdate = onUpdate
        self._selectedRole = State(initialValue: user.role)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // User Info
                VStack(spacing: 16) {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(user.firstName.prefix(1) + user.lastName.prefix(1))
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 4) {
                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(user.college)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Role Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Role")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            RoleSelectionRow(
                                role: role,
                                isSelected: selectedRole == role
                            ) {
                                selectedRole = role
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Update Button
                Button(action: updateRole) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text("Update Role")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedRole != user.role ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading || selectedRole == user.role)
            }
            .padding()
            .navigationTitle("Update Role")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func updateRole() {
        isLoading = true
        
        AdminService.shared.updateUserRole(userId: user.id, role: selectedRole)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                },
                receiveValue: { updatedUser in
                    onUpdate(updatedUser)
                    dismiss()
                }
            )
            .store(in: &cancellables)
    }
}

struct RoleSelectionRow: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: role.systemImage)
                    .font(.title3)
                    .foregroundColor(roleColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(role.displayName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(roleDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var roleColor: Color {
        switch role {
        case .admin:
            return .red
        case .organizer:
            return .orange
        case .participant:
            return .blue
        }
    }
    
    private var roleDescription: String {
        switch role {
        case .admin:
            return "Full system access and user management"
        case .organizer:
            return "Can create events and manage announcements"
        case .participant:
            return "Can view events and register for participation"
        }
    }
}

#Preview {
    UserManagementView()
}