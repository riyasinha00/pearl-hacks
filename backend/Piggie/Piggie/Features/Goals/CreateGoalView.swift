import SwiftUI

struct CreateGoalView: View {
    @Binding var isPresented: Bool
    let onGoalCreated: () -> Void
    @State private var name = ""
    @State private var targetAmount: Double = 100
    @State private var icon = "🎯"
    @State private var isDefault = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let icons = ["🎯", "🏠", "🚗", "✈️", "🎓", "💍", "💻", "🎮", "📱", "🎨", "🎵", "🏖️"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name")
                                .font(.headline)
                                .foregroundColor(.piggieText)
                            
                            TextField("e.g., New Laptop", text: $name)
                                .textFieldStyle(PiggieTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Amount: $\(Int(targetAmount))")
                                .font(.headline)
                                .foregroundColor(.piggieText)
                            
                            Slider(value: $targetAmount, in: 10...10000, step: 10)
                                .tint(.piggieSage)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.headline)
                                .foregroundColor(.piggieText)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                                ForEach(icons, id: \.self) { emoji in
                                    Button(action: {
                                        icon = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 40))
                                            .frame(width: 60, height: 60)
                                            .background(icon == emoji ? Color.piggieSage.opacity(0.3) : Color.white)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        Toggle("Set as default goal", isOn: $isDefault)
                            .tint(.piggieSage)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: createGoal) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Goal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PiggieButtonStyle())
                        .disabled(name.isEmpty || isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func createGoal() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                struct GoalCreate: Encodable {
                    let name: String
                    let target_cents: Int
                    let icon: String
                    let is_default: Bool
                }
                
                let _: GoalResponse = try await APIClient.shared.request(
                    endpoint: "/goals",
                    method: .POST,
                    body: GoalCreate(
                        name: name,
                        target_cents: Int(targetAmount * 100),
                        icon: icon,
                        is_default: isDefault
                    )
                )
                
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                    onGoalCreated()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct EditGoalView: View {
    let goal: GoalResponse
    @Binding var isPresented: Bool
    @State private var name: String
    @State private var targetAmount: Double
    @State private var icon: String
    @State private var isDefault: Bool
    @State private var isLoading = false
    @State private var showDeleteConfirmation = false
    
    init(goal: GoalResponse, isPresented: Binding<Bool>) {
        self.goal = goal
        _isPresented = isPresented
        _name = State(initialValue: goal.name)
        _targetAmount = State(initialValue: Double(goal.target_cents) / 100.0)
        _icon = State(initialValue: goal.icon)
        _isDefault = State(initialValue: goal.is_default)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                // Similar to CreateGoalView but with update/delete
                Text("Edit Goal")
                    .padding()
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
