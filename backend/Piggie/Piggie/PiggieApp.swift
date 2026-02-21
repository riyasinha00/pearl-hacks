import SwiftUI
import SwiftData

@main
struct PiggieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [UserProfile.self, CachedTransaction.self, Wallet.self, Goal.self, Allocation.self, QueuedEvent.self])
        }
    }
}
