import SwiftUI

struct PlaidConnectionCard: View {
    @Binding var plaidItem: PlaidItemResponse?
    @State private var isConnecting = false
    @State private var showPlaidLink = false
    
    var body: some View {
        PiggieCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: plaidItem != nil ? "checkmark.circle.fill" : "link.circle")
                        .font(.title2)
                        .foregroundColor(plaidItem != nil ? .green : .piggieSage)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plaidItem != nil ? "Bank Connected" : "Connect Bank")
                            .font(.headline)
                            .foregroundColor(.piggieText)
                        
                        if let item = plaidItem {
                            Text(item.institution_name ?? "Connected")
                                .font(.caption)
                                .foregroundColor(.piggieTextLight)
                            
                            if let lastSync = item.last_sync {
                                Text("Last synced: \(formatDate(lastSync))")
                                    .font(.caption2)
                                    .foregroundColor(.piggieTextLight)
                            }
                        } else {
                            Text("Connect via Plaid to track real transactions")
                                .font(.caption)
                                .foregroundColor(.piggieTextLight)
                        }
                    }
                    
                    Spacer()
                }
                
                if plaidItem != nil {
                    Button(action: syncTransactions) {
                        HStack {
                            if isConnecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                                Text("Sync Now")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.piggieSage)
                        .cornerRadius(8)
                    }
                    .disabled(isConnecting)
                } else {
                    Button(action: {
                        showPlaidLink = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Connect Bank")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.piggieSage)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showPlaidLink) {
            PlaidLinkView(isPresented: $showPlaidLink, onSuccess: {
                plaidItem = nil // Will reload
                showPlaidLink = false
            })
        }
    }
    
    private func syncTransactions() {
        isConnecting = true
        Task {
            do {
                struct SyncResponse: Decodable {
                    let status: String
                }
                let _: SyncResponse = try await APIClient.shared.request(
                    endpoint: "/plaid/sync",
                    method: .POST
                )
                await MainActor.run {
                    isConnecting = false
                    // Reload transactions
                    TransactionManager.shared.fetchTransactions()
                }
            } catch {
                await MainActor.run {
                    isConnecting = false
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
