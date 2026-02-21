import SwiftUI

struct TransactionRow: View {
    let transaction: CachedTransaction
    
    var body: some View {
        PiggieCard {
            HStack {
                // Merchant icon/emoji
                ZStack {
                    Circle()
                        .fill(Color.piggiePeach.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Text(merchantEmoji)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.merchant)
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    if let category = transaction.category {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.piggieTextLight)
                    }
                    
                    Text(formatDate(transaction.timestamp))
                        .font(.caption2)
                        .foregroundColor(.piggieTextLight)
                }
                
                Spacer()
                
                CurrencyText(cents: transaction.amountCents, font: .headline)
                    .foregroundColor(.piggieText)
            }
        }
        .padding(.horizontal)
    }
    
    private var merchantEmoji: String {
        let merchant = transaction.merchant.lowercased()
        if merchant.contains("coffee") || merchant.contains("starbucks") {
            return "☕️"
        } else if merchant.contains("food") || merchant.contains("restaurant") {
            return "🍔"
        } else if merchant.contains("shopping") || merchant.contains("store") {
            return "🛍️"
        } else if merchant.contains("uber") || merchant.contains("lyft") {
            return "🚗"
        } else {
            return "💳"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
