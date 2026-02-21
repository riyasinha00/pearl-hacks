import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
                    .onAppear {
                        TransactionManager.shared.setModelContext(modelContext)
                    }
            } else {
                AuthView()
            }
        }
        .onAppear {
            authManager.checkAuthStatus()
        }
    }
}
