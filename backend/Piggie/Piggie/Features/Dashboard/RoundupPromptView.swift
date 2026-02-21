import SwiftUI

struct RoundupPromptView: View {
    let transaction: TransactionResponse
    @Binding var isPresented: Bool
    @State private var roundupCents: Int = 0
    @State private var isLoading = false
    @State private var selectedGoalId: Int?
    @State private var goals: [GoalResponse] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    PiggieMascot(size: 100, bounce: true)
                    
                    Text("Round up this transaction?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.piggieText)
                    
                    PiggieCard {
                        VStack(spacing: 16) {
                            HStack {
                                Text(transaction.merchant)
                                    .font(.headline)
                                Spacer()
                                CurrencyText(cents: transaction.amount_cents)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Round-up amount:")
                                    .font(.subheadline)
                                    .foregroundColor(.piggieTextLight)
                                Spacer()
                                CurrencyText(cents: roundupCents, font: .headline)
                                    .foregroundColor(.piggieSage)
                            }
                            
                            if !goals.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Allocate to goal:")
                                        .font(.subheadline)
                                        .foregroundColor(.piggieTextLight)
                                    
                                    Picker("Goal", selection: $selectedGoalId) {
                                        Text("Default").tag(nil as Int?)
                                        ForEach(goals, id: \.id) { goal in
                                            Text("\(goal.icon) \(goal.name)").tag(goal.id as Int?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Skip")
                                .font(.headline)
                                .foregroundColor(.piggieTextLight)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: applyRoundup) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Round Up")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PiggieButtonStyle())
                        .disabled(isLoading)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Round Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                calculateRoundup()
                loadGoals()
            }
        }
    }
    
    private func calculateRoundup() {
        let amount = transaction.amount_cents
        if amount % 100 == 0 {
            roundupCents = 100 // Exactly on dollar, round up by $1
        } else {
            roundupCents = 100 - (amount % 100) // Round to next dollar
        }
    }
    
    private func loadGoals() {
        Task {
            do {
                let fetched: [GoalResponse] = try await APIClient.shared.request(endpoint: "/goals")
                await MainActor.run {
                    self.goals = fetched
                }
            } catch {
                print("Failed to load goals: \(error)")
            }
        }
    }
    
    private func applyRoundup() {
        isLoading = true
        
        Task {
            do {
                struct RoundupRequest: Encodable {
                    let transaction_id: String
                    let goal_id: Int?
                }
                
                let _: RoundupResponse = try await APIClient.shared.request(
                    endpoint: "/roundup",
                    method: .POST,
                    body: RoundupRequest(
                        transaction_id: transaction.transaction_id,
                        goal_id: selectedGoalId
                    )
                )
                
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                    
                    // Show success animation
                    withAnimation {
                        // Could add a toast here
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
