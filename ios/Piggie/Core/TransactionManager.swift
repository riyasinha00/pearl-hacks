import Foundation
import SwiftData

class TransactionManager: ObservableObject {
    static let shared = TransactionManager()
    
    @Published var transactions: [TransactionResponse] = []
    private var pollingTimer: Timer?
    private var modelContext: ModelContext?
    
    private init() {}
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func startPolling() {
        stopPolling()
        fetchTransactions()
        
        // Poll every 10 seconds
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.fetchTransactions()
        }
    }
    
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    func fetchTransactions() {
        Task {
            do {
                let fetched: [TransactionResponse] = try await APIClient.shared.request(endpoint: "/transactions")
                
                await MainActor.run {
                    self.transactions = fetched
                    self.cacheTransactions(fetched)
                }
            } catch {
                print("Failed to fetch transactions: \(error)")
            }
        }
    }
    
    private func cacheTransactions(_ transactions: [TransactionResponse]) {
        guard let context = modelContext else { return }
        
        for txn in transactions {
            // Check if already cached
            let descriptor = FetchDescriptor<CachedTransaction>(
                predicate: #Predicate { $0.transactionId == txn.transaction_id }
            )
            
            if let existing = try? context.fetch(descriptor).first {
                // Update existing
                existing.amountCents = txn.amount_cents
                existing.merchant = txn.merchant
                existing.category = txn.category
                existing.timestamp = txn.timestamp
                existing.source = txn.source
                existing.pending = txn.pending
            } else {
                // Create new
                let cached = CachedTransaction(
                    transactionId: txn.transaction_id,
                    amountCents: txn.amount_cents,
                    merchant: txn.merchant,
                    category: txn.category,
                    timestamp: txn.timestamp,
                    source: txn.source,
                    pending: txn.pending
                )
                context.insert(cached)
            }
        }
        
        try? context.save()
    }
}
