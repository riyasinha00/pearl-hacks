import SwiftUI
import SwiftData

struct WalletsView: View {
    @Query private var cachedWallet: [Wallet]
    @State private var wallet: WalletResponse?
    @State private var allocation: AllocationResponse?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Savings wallet
                        WalletCard(
                            title: "Savings",
                            icon: "💰",
                            amountCents: wallet?.savings_cents ?? 0,
                            color: .piggieSage
                        )
                        
                        // Investing wallet
                        WalletCard(
                            title: "Investing",
                            icon: "📈",
                            amountCents: wallet?.investing_cents ?? 0,
                            color: .piggiePeach
                        )
                        
                        // Allocation settings
                        if let allocation = allocation {
                            AllocationCard(allocation: allocation)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Wallets")
            .onAppear {
                loadWallet()
                loadAllocation()
            }
        }
    }
    
    private func loadWallet() {
        Task {
            do {
                let fetched: WalletResponse = try await APIClient.shared.request(endpoint: "/wallet")
                await MainActor.run {
                    wallet = fetched
                }
            } catch {
                print("Failed to load wallet: \(error)")
            }
        }
    }
    
    private func loadAllocation() {
        Task {
            do {
                let fetched: AllocationResponse = try await APIClient.shared.request(endpoint: "/allocation")
                await MainActor.run {
                    allocation = fetched
                }
            } catch {
                print("Failed to load allocation: \(error)")
            }
        }
    }
}

struct WalletCard: View {
    let title: String
    let icon: String
    let amountCents: Int
    let color: Color
    
    var body: some View {
        PiggieCard {
            HStack {
                Text(icon)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    CurrencyText(cents: amountCents, font: .title, fontWeight: .bold)
                }
                
                Spacer()
            }
        }
    }
}

struct AllocationCard: View {
    let allocation: AllocationResponse
    @State private var showEdit = false
    
    var body: some View {
        PiggieCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Allocation Settings")
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    Spacer()
                    
                    Button(action: {
                        showEdit = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.piggieSage)
                    }
                }
                
                VStack(spacing: 12) {
                    AllocationRow(
                        label: "Savings",
                        percent: allocation.savings_percent,
                        color: .piggieSage
                    )
                    
                    AllocationRow(
                        label: "Investing",
                        percent: allocation.investing_percent,
                        color: .piggiePeach
                    )
                    
                    AllocationRow(
                        label: "Goals",
                        percent: allocation.goals_percent,
                        color: .piggiePink
                    )
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditAllocationView(allocation: allocation, isPresented: $showEdit)
        }
    }
}

struct AllocationRow: View {
    let label: String
    let percent: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.piggieText)
                
                Spacer()
                
                Text("\(Int(percent))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(percent / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}
