//
//  Settings.swift
//  iOSTraining
//
//  Created by Jollibe Dablo - INTERN on 3/2/26.
//

import SwiftUI

struct AccountInformationView: View {
    var body: some View { placeholderView(title: "Account Information", icon: "person.circle.fill") }
}
struct PrivacySecurityView: View {
    var body: some View { placeholderView(title: "Privacy & Security", icon: "lock.shield.fill") }
}
struct PaymentInformationView: View {
    var body: some View { placeholderView(title: "Payment Information", icon: "creditcard.fill") }
}
struct NotificationsView: View {
    var body: some View { placeholderView(title: "Notifications", icon: "bell.fill") }
}
struct TermsConditionsView: View {
    var body: some View { placeholderView(title: "Terms & Conditions", icon: "doc.text.fill") }
}
struct HelpCenterView: View {
    var body: some View { placeholderView(title: "Help Center", icon: "questionmark.circle.fill") }
}

private func placeholderView(title: String, icon: String) -> some View {
    VStack(spacing: 16) {
        Image(systemName: icon)
            .font(.system(size: 56))
            .foregroundColor(.brandGreen.opacity(0.4))
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
        Text("This section is coming soon.")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(UIColor.systemGroupedBackground))
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
}

// MARK: - Settings Row Model
struct SettingsRow: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
}

// MARK: - Main Settings View
struct SettingsView: View {

    @State private var showLogoutAlert = false
    @State private var navigateTo: String? = nil

    private let menuSections: [[SettingsRow]] = [
        [
            SettingsRow(icon: "person.fill",         iconColor: .blue,       title: "Account Information"),
            SettingsRow(icon: "lock.shield.fill",     iconColor: .indigo,     title: "Privacy & Security"),
            SettingsRow(icon: "creditcard.fill",      iconColor: .brandGreen, title: "Payment Information"),
        ],
        [
            SettingsRow(icon: "bell.fill",            iconColor: .orange,     title: "Notifications"),
            SettingsRow(icon: "doc.text.fill",        iconColor: .gray,       title: "Terms & Conditions"),
            SettingsRow(icon: "questionmark.circle.fill", iconColor: .teal,   title: "Help Center"),
        ]
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileCard
                    menuGroupsView
                    logoutButton
                }
                .padding(.vertical, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            // Navigation destinations
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "Account Information": AccountInformationView()
                case "Privacy & Security":  PrivacySecurityView()
                case "Payment Information": PaymentInformationView()
                case "Notifications":       NotificationsView()
                case "Terms & Conditions":  TermsConditionsView()
                case "Help Center":         HelpCenterView()
                default:                    EmptyView()
                }
            }
        }
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Log Out", role: .destructive) {
                logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.brandGreenSoft)
                    .frame(width: 64, height: 64)
                Image(systemName: "person.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.brandGreen)
            }

            // Name + membership
            VStack(alignment: .leading, spacing: 5) {
                Text(UserDefaults.standard.string(forKey: "userName") ?? "Guest User")
                    .font(.headline)
                    .fontWeight(.bold)

                HStack(spacing: 5) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.yellow)
                    Text("VIP Member")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.12))
                .cornerRadius(20)
            }

            Spacer()

            
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Menu Groups
    private var menuGroupsView: some View {
        VStack(spacing: 16) {
            ForEach(menuSections.indices, id: \.self) { sectionIndex in
                VStack(spacing: 0) {
                    ForEach(Array(menuSections[sectionIndex].enumerated()), id: \.element.id) { index, row in
                        NavigationLink(value: row.title) {
                            settingsRowView(row: row)
                        }
                        .buttonStyle(.plain)

                        if index < menuSections[sectionIndex].count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Settings Row View
    private func settingsRowView(row: SettingsRow) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(row.iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: row.icon)
                    .font(.system(size: 16))
                    .foregroundColor(row.iconColor)
            }
            .padding(.leading, 16)

            Text(row.title)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.trailing, 16)
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                .padding(.leading, 16)

                Text("Log Out")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                Spacer()
            }
            .padding(.vertical, 14)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Logout Action
    private func logout() {
        // Clear all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "cart_items")
        UserDefaults.standard.removeObject(forKey: "checkout_draft")
        UserDefaults.standard.removeObject(forKey: "isDiscountModalSeen")
        UserDefaults.standard.synchronize()

        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let delegate = scene.delegate as? SceneDelegate {
                delegate.showLoginScreen(animated: true)
            }
        }
    }
}

#Preview {
    SettingsView()
}
