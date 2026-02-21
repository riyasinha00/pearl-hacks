import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var transactionManager = TransactionManager.shared
    @Query private var cachedTransactions: [CachedTransaction]
    @Environment(\.modelContext) private var modelContext
    
    @State private var plaidItem: PlaidItemResponse?
    @State private var showRoundupPrompt = false
    @State private var pendingRoundup: TransactionResponse?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hi, \(authManager.currentUser?.name ?? "there")! 👋")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.piggieText)
                                
                                Text("Let's save together!")
                                    .font(.subheadline)
                                    .foregroundColor(.piggieTextLight)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                authManager.logout()
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.piggieSage)
                            }
                        }
                        .padding()
                        
                        // Plaid connection card
                        PlaidConnectionCard(plaidItem: $plaidItem)
                        
                        // Recent transactions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Transactions")
                                .font(.headline)
                                .foregroundColor(.piggieText)
                                .padding(.horizontal)
                            
                            ForEach(Array(cachedTransactions.prefix(5)), id: \.transactionId) { transaction in
                                TransactionRow(transaction: transaction)
                                    .onTapGesture {
                                        // Show round-up prompt
                                        showRoundupPrompt = true
                                        pendingRoundup = TransactionResponse(
                                            id: 0,
                                            transaction_id: transaction.transactionId,
                                            amount_cents: transaction.amountCents,
                                            merchant: transaction.merchant,
                                            category: transaction.category,
                                            timestamp: transaction.timestamp,
                                            source: transaction.source,
                                            pending: transaction.pending
                                        )
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Piggie")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadPlaidItem()
                transactionManager.startPolling()
            }
            .sheet(isPresented: $showRoundupPrompt) {
                if let transaction = pendingRoundup {
                    RoundupPromptView(transaction: transaction, isPresented: $showRoundupPrompt)
                }
            }
        }
    }
    
    private func loadPlaidItem() {
        Task {
            do {
                let item: PlaidItemResponse = try await APIClient.shared.request(endpoint: "/plaid/item")
                await MainActor.run {
                    plaidItem = item
                }
            } catch {
                // No Plaid item connected, that's okay
            }
        }
    }
}
