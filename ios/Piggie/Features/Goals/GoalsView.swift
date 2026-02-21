import SwiftUI

struct GoalsView: View {
    @State private var goals: [GoalResponse] = []
    @State private var showCreateGoal = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                if goals.isEmpty {
                    VStack(spacing: 20) {
                        PiggieMascot(size: 100)
                        
                        Text("No goals yet")
                            .font(.headline)
                            .foregroundColor(.piggieText)
                        
                        Text("Create your first savings goal!")
                            .font(.subheadline)
                            .foregroundColor(.piggieTextLight)
                        
                        Button(action: {
                            showCreateGoal = true
                        }) {
                            Text("Create Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PiggieButtonStyle())
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(goals, id: \.id) { goal in
                                GoalCard(goal: goal)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateGoal = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.piggieSage)
                    }
                }
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView(isPresented: $showCreateGoal, onGoalCreated: {
                    loadGoals()
                })
            }
            .onAppear {
                loadGoals()
            }
        }
    }
    
    private func loadGoals() {
        isLoading = true
        Task {
            do {
                let fetched: [GoalResponse] = try await APIClient.shared.request(endpoint: "/goals")
                await MainActor.run {
                    goals = fetched
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

struct GoalCard: View {
    let goal: GoalResponse
    @State private var showEdit = false
    
    private var progress: Double {
        guard goal.target_cents > 0 else { return 0 }
        return min(Double(goal.current_cents) / Double(goal.target_cents), 1.0)
    }
    
    var body: some View {
        PiggieCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(goal.icon)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.name)
                            .font(.headline)
                            .foregroundColor(.piggieText)
                        
                        if goal.is_default {
                            Text("Default Goal")
                                .font(.caption)
                                .foregroundColor(.piggieSage)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showEdit = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.piggieTextLight)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        CurrencyText(cents: goal.current_cents, font: .title2, fontWeight: .bold)
                            .foregroundColor(.piggieSage)
                        
                        Text("of")
                            .foregroundColor(.piggieTextLight)
                        
                        CurrencyText(cents: goal.target_cents, font: .subheadline)
                            .foregroundColor(.piggieTextLight)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)
                                .cornerRadius(6)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.piggieSage, Color.piggiePeach],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                                .cornerRadius(6)
                        }
                    }
                    .frame(height: 12)
                    
                    Text("\(Int(progress * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.piggieTextLight)
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            EditGoalView(goal: goal, isPresented: $showEdit)
        }
    }
}
