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
        print("AuthManager: Checking auth status")
        if KeychainHelper.shared.getToken() != nil {
            isAuthenticated = true
            print("AuthManager: Token found in keychain. Marking authenticated and loading profile...")
            loadUserProfile()
        } else {
            isAuthenticated = false
            print("AuthManager: No token found. User is not authenticated.")
        }
    }
    
    func login(token: String) {
        print("AuthManager: Login called. Saving token and loading profile...")
        KeychainHelper.shared.saveToken(token)
        isAuthenticated = true
        print("AuthManager: Token saved. isAuthenticated = true. Loading profile...")
        loadUserProfile()
    }
    
    func logout() {
        print("AuthManager: Logout called. Deleting token and clearing user.")
        KeychainHelper.shared.deleteToken()
        isAuthenticated = false
        currentUser = nil
    }
    
    private func loadUserProfile() {
        print("AuthManager: loadUserProfile() starting")
        Task {
            do {
                print("AuthManager: Requesting /auth/me")
                let user: UserResponse = try await APIClient.shared.request(endpoint: "/auth/me")
                await MainActor.run {
                    print("AuthManager: /auth/me success for \\(user.email)")
                    self.currentUser = UserProfile(
                        publicId: user.public_id,
                        email: user.email,
                        name: user.name
                    )
                }
            } catch {
                print("AuthManager: Failed to load user profile: \\(error)")
            }
        }
    }
}

struct UserResponse: Decodable {
    let public_id: String
    let email: String
    let name: String
}
