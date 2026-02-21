import SwiftUI

struct EditAllocationView: View {
    let allocation: AllocationResponse
    @Binding var isPresented: Bool
    @State private var savingsPercent: Double
    @State private var investingPercent: Double
    @State private var goalsPercent: Double
    @State private var isLoading = false
    
    init(allocation: AllocationResponse, isPresented: Binding<Bool>) {
        self.allocation = allocation
        _isPresented = isPresented
        _savingsPercent = State(initialValue: allocation.savings_percent)
        _investingPercent = State(initialValue: allocation.investing_percent)
        _goalsPercent = State(initialValue: allocation.goals_percent)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Adjust your allocation percentages")
                        .font(.headline)
                        .foregroundColor(.piggieText)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 20) {
                        AllocationSlider(
                            label: "Savings",
                            value: $savingsPercent,
                            color: .piggieSage,
                            otherValues: [$investingPercent, $goalsPercent]
                        )
                        
                        AllocationSlider(
                            label: "Investing",
                            value: $investingPercent,
                            color: .piggiePeach,
                            otherValues: [$savingsPercent, $goalsPercent]
                        )
                        
                        AllocationSlider(
                            label: "Goals",
                            value: $goalsPercent,
                            color: .piggiePink,
                            otherValues: [$savingsPercent, $investingPercent]
                        )
                    }
                    
                    Text("Total: \(Int(savingsPercent + investingPercent + goalsPercent))%")
                        .font(.subheadline)
                        .foregroundColor(abs(savingsPercent + investingPercent + goalsPercent - 100) < 0.01 ? .green : .red)
                    
                    Button(action: save) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PiggieButtonStyle())
                    .disabled(abs(savingsPercent + investingPercent + goalsPercent - 100) > 0.01 || isLoading)
                }
                .padding()
            }
            .navigationTitle("Edit Allocation")
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
    
    private func save() {
        isLoading = true
        
        Task {
            do {
                struct AllocationUpdate: Encodable {
                    let savings_percent: Double
                    let investing_percent: Double
                    let goals_percent: Double
                }
                
                let _: AllocationResponse = try await APIClient.shared.request(
                    endpoint: "/allocation",
                    method: .PUT,
                    body: AllocationUpdate(
                        savings_percent: savingsPercent,
                        investing_percent: investingPercent,
                        goals_percent: goalsPercent
                    )
                )
                
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

struct AllocationSlider: View {
    let label: String
    @Binding var value: Double
    let color: Color
    let otherValues: [Binding<Double>]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.piggieText)
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: 0...100, step: 1)
                .tint(color)
                .onChange(of: value) { oldValue, newValue in
                    // Adjust other values to maintain sum of 100
                    let diff = newValue - oldValue
                    let totalOther = otherValues.reduce(0) { $0 + $1.wrappedValue }
                    
                    if totalOther > 0 {
                        for binding in otherValues {
                            let proportion = binding.wrappedValue / totalOther
                            binding.wrappedValue = max(0, binding.wrappedValue - diff * proportion)
                        }
                    }
                }
        }
    }
}
