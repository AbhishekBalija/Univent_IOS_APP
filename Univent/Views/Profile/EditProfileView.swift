//
//  EditProfileView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI
import Combine

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var college: String
    
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var cancellables = Set<AnyCancellable>()
    
    init() {
        let currentUser = AuthManager.shared.currentUser
        self._firstName = State(initialValue: currentUser?.firstName ?? "")
        self._lastName = State(initialValue: currentUser?.lastName ?? "")
        self._college = State(initialValue: currentUser?.college ?? "")
    }
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !college.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var hasChanges: Bool {
        let currentUser = authManager.currentUser
        return firstName != (currentUser?.firstName ?? "") ||
               lastName != (currentUser?.lastName ?? "") ||
               college != (currentUser?.college ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("First Name")
                        Spacer()
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 200)
                    }
                    
                    HStack {
                        Text("Last Name")
                        Spacer()
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 200)
                    }
                    
                    HStack {
                        Text("College")
                        Spacer()
                        TextField("College", text: $college)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 200)
                    }
                }
                
                Section("Account Information") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authManager.currentUser?.email ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Role")
                        Spacer()
                        RoleBadge(role: authManager.currentUser?.role ?? .participant)
                    }
                }
                
                Section {
                    Text("Your email and role cannot be changed. Contact an administrator if you need to update these fields.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateProfile()
                    }
                    .disabled(!isFormValid || !hasChanges || isLoading)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func updateProfile() {
        isLoading = true
        
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCollege = college.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let currentUser = authManager.currentUser
        
        authManager.updateProfile(
            firstName: trimmedFirstName != currentUser?.firstName ? trimmedFirstName : nil,
            lastName: trimmedLastName != currentUser?.lastName ? trimmedLastName : nil,
            college: trimmedCollege != currentUser?.college ? trimmedCollege : nil
        )
        .sink(
            receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            },
            receiveValue: { _ in
                dismiss()
            }
        )
        .store(in: &cancellables)
    }
}

#Preview {
    EditProfileView()
}