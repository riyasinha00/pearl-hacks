import SwiftUI

struct MainTabView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            WalletsView()
                .tabItem {
                    Label("Wallets", systemImage: "wallet.pass.fill")
                }
                .tag(1)
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(2)
            
            InvestingView()
                .tabItem {
                    Label("Investing", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)
        }
        .accentColor(.piggieSage)
    }
}
