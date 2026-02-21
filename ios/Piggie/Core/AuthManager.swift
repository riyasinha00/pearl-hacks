import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if KeychainHelper.shared.getToken() != nil {
            isAuthenticated = true
            loadUserProfile()
        } else {
            isAuthenticated = false
        }
    }
    
    func login(token: String) {
        KeychainHelper.shared.saveToken(token)
        isAuthenticated = true
        loadUserProfile()
    }
    
    func logout() {
        KeychainHelper.shared.deleteToken()
        isAuthenticated = false
        currentUser = nil
    }
    
    private func loadUserProfile() {
        Task {
            do {
                let user: UserResponse = try await APIClient.shared.request(endpoint: "/auth/me")
                await MainActor.run {
                    self.currentUser = UserProfile(
                        publicId: user.public_id,
                        email: user.email,
                        name: user.name,
                        school: user.school,
                        gradYear: user.grad_year,
                        monthlyGoalCents: user.monthly_goal_cents
                    )
                }
            } catch {
                print("Failed to load user profile: \(error)")
            }
        }
    }
}

struct UserResponse: Decodable {
    let public_id: String
    let email: String
    let name: String
    let school: String
    let grad_year: Int
    let monthly_goal_cents: Int
}
