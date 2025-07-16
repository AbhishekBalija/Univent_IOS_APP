//
//  SystemSettingsView.swift
//  Univent
//
//  Created by Abhishek AN on 16/07/25.
//

import SwiftUI

struct SystemSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var autoApprovalEnabled = false
    @State private var maintenanceMode = false
    @State private var maxEventCapacity = 500
    @State private var registrationDeadlineDays = 1
    @State private var systemHealthStatus = "Operational"
    
    var body: some View {
        NavigationView {
            Form {
                Section("General Settings") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Auto-approve Events", isOn: $autoApprovalEnabled)
                    Toggle("Maintenance Mode", isOn: $maintenanceMode)
                }
                
                Section("Event Settings") {
                    HStack {
                        Text("Max Event Capacity")
                        Spacer()
                        TextField("Capacity", value: $maxEventCapacity, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Registration Deadline (days)")
                        Spacer()
                        TextField("Days", value: $registrationDeadlineDays, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                }
                
                Section("System Health") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(systemHealthStatus)
                            .foregroundColor(systemHealthStatus == "Operational" ? .green : .red)
                            .fontWeight(.medium)
                    }
                    
                    Button("Run System Diagnostics") {
                        runDiagnostics()
                    }
                    .foregroundColor(.blue)
                }
                
                Section("Data Management") {
                    Button("Export User Data") {
                        exportUserData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Export Event Data") {
                        exportEventData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear Cache") {
                        clearCache()
                    }
                    .foregroundColor(.orange)
                }
                
                Section("Danger Zone") {
                    Button("Reset All Settings") {
                        resetSettings()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("System Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func runDiagnostics() {
        // Simulate system diagnostics
        systemHealthStatus = "Running diagnostics..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            systemHealthStatus = "Operational"
        }
    }
    
    private func exportUserData() {
        // Handle user data export
        print("Exporting user data...")
    }
    
    private func exportEventData() {
        // Handle event data export
        print("Exporting event data...")
    }
    
    private func clearCache() {
        // Handle cache clearing
        print("Clearing cache...")
    }
    
    private func resetSettings() {
        // Reset all settings to default
        notificationsEnabled = true
        autoApprovalEnabled = false
        maintenanceMode = false
        maxEventCapacity = 500
        registrationDeadlineDays = 1
    }
    
    private func saveSettings() {
        // Save settings to backend
        print("Saving system settings...")
    }
}

#Preview {
    SystemSettingsView()
}