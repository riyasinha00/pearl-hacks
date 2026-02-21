import Foundation
import SwiftData

@Model
final class UserProfile {
    var publicId: String
    var email: String
    var name: String
    var school: String
    var gradYear: Int
    var monthlyGoalCents: Int
    
    init(publicId: String, email: String, name: String, school: String, gradYear: Int, monthlyGoalCents: Int) {
        self.publicId = publicId
        self.email = email
        self.name = name
        self.school = school
        self.gradYear = gradYear
        self.monthlyGoalCents = monthlyGoalCents
    }
}

@Model
final class CachedTransaction {
    var transactionId: String
    var amountCents: Int
    var merchant: String
    var category: String?
    var timestamp: Date
    var source: String
    var pending: Bool
    
    init(transactionId: String, amountCents: Int, merchant: String, category: String?, timestamp: Date, source: String, pending: Bool) {
        self.transactionId = transactionId
        self.amountCents = amountCents
        self.merchant = merchant
        self.category = category
        self.timestamp = timestamp
        self.source = source
        self.pending = pending
    }
}

@Model
final class Wallet {
    var savingsCents: Int
    var investingCents: Int
    var lastUpdated: Date
    
    init(savingsCents: Int, investingCents: Int, lastUpdated: Date) {
        self.savingsCents = savingsCents
        self.investingCents = investingCents
        self.lastUpdated = lastUpdated
    }
}

@Model
final class Goal {
    var id: Int
    var name: String
    var targetCents: Int
    var currentCents: Int
    var icon: String
    var isDefault: Bool
    var createdAt: Date
    
    init(id: Int, name: String, targetCents: Int, currentCents: Int, icon: String, isDefault: Bool, createdAt: Date) {
        self.id = id
        self.name = name
        self.targetCents = targetCents
        self.currentCents = currentCents
        self.icon = icon
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
}

@Model
final class Allocation {
    var savingsPercent: Double
    var investingPercent: Double
    var goalsPercent: Double
    
    init(savingsPercent: Double, investingPercent: Double, goalsPercent: Double) {
        self.savingsPercent = savingsPercent
        self.investingPercent = investingPercent
        self.goalsPercent = goalsPercent
    }
}

@Model
final class QueuedEvent {
    var eventType: String
    var metadata: String?
    var createdAt: Date
    
    init(eventType: String, metadata: String?, createdAt: Date) {
        self.eventType = eventType
        self.metadata = metadata
        self.createdAt = createdAt
    }
}

struct TransactionResponse: Decodable {
    let id: Int
    let transaction_id: String
    let amount_cents: Int
    let merchant: String
    let category: String?
    let timestamp: Date
    let source: String
    let pending: Bool
}

struct WalletResponse: Decodable {
    let savings_cents: Int
    let investing_cents: Int
}

struct GoalResponse: Decodable {
    let id: Int
    let name: String
    let target_cents: Int
    let current_cents: Int
    let icon: String
    let is_default: Bool
    let created_at: Date
}

struct AllocationResponse: Decodable {
    let savings_percent: Double
    let investing_percent: Double
    let goals_percent: Double
}

struct PlaidItemResponse: Decodable {
    let item_id: String
    let institution_name: String?
    let last_sync: Date?
}

struct RoundupResponse: Decodable {
    let roundup_cents: Int
    let savings_cents: Int
    let investing_cents: Int
    let goals_cents: Int
    let goal_id: Int?
}

struct PortfolioSummary: Decodable {
    let current_value_cents: Int
    let total_return_cents: Int
    let total_return_percent: Double
    let today_return_cents: Int
    let today_return_percent: Double
}
