import SwiftUI
import Charts

struct InvestingView: View {
    @State private var portfolio: PortfolioSummary?
    @State private var chartData: [(Date, Int)] = []
    @State private var selectedTimeframe: Timeframe = .allTime
    @State private var isLoading = false
    
    enum Timeframe: String, CaseIterable {
        case today = "Today"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .piggieSage))
                } else if let portfolio = portfolio {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Portfolio summary card
                            PiggieCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Piggie Index Fund")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.piggieText)
                                        
                                        Spacer()
                                        
                                        Text("📈")
                                            .font(.system(size: 40))
                                    }
                                    
                                    CurrencyText(cents: portfolio.current_value_cents, font: .title, fontWeight: .bold)
                                        .foregroundColor(.piggieSage)
                                    
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading) {
                                            Text("Today")
                                                .font(.caption)
                                                .foregroundColor(.piggieTextLight)
                                            
                                            HStack {
                                                Text(portfolio.today_return_percent >= 0 ? "+" : "")
                                                    .foregroundColor(portfolio.today_return_percent >= 0 ? .green : .red)
                                                
                                                Text(String(format: "%.2f%%", portfolio.today_return_percent))
                                                    .font(.headline)
                                                    .foregroundColor(portfolio.today_return_percent >= 0 ? .green : .red)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("All Time")
                                                .font(.caption)
                                                .foregroundColor(.piggieTextLight)
                                            
                                            HStack {
                                                Text(portfolio.total_return_percent >= 0 ? "+" : "")
                                                    .foregroundColor(portfolio.total_return_percent >= 0 ? .green : .red)
                                                
                                                Text(String(format: "%.2f%%", portfolio.total_return_percent))
                                                    .font(.headline)
                                                    .foregroundColor(portfolio.total_return_percent >= 0 ? .green : .red)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            // Chart
                            if !chartData.isEmpty {
                                PiggieCard {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Picker("Timeframe", selection: $selectedTimeframe) {
                                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                                Text(timeframe.rawValue).tag(timeframe)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                        
                                        Chart {
                                            ForEach(filteredChartData, id: \.0) { data in
                                                LineMark(
                                                    x: .value("Date", data.0),
                                                    y: .value("Value", Double(data.1) / 100.0)
                                                )
                                                .foregroundStyle(Color.piggieSage)
                                                .interpolationMethod(.catmullRom)
                                            }
                                        }
                                        .frame(height: 200)
                                        .chartXAxis {
                                            AxisMarks(values: .automatic) { _ in
                                                AxisGridLine()
                                                AxisValueLabel(format: .dateTime.month().day())
                                            }
                                        }
                                        .chartYAxis {
                                            AxisMarks { _ in
                                                AxisGridLine()
                                                AxisValueLabel(format: .currency(code: "USD"))
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            
                            // Info card
                            PiggieCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("About Piggie Index Fund")
                                        .font(.headline)
                                        .foregroundColor(.piggieText)
                                    
                                    Text("This is a simulated portfolio that tracks your round-up investments. Returns are calculated using a deterministic algorithm based on your account.")
                                        .font(.subheadline)
                                        .foregroundColor(.piggieTextLight)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        PiggieMascot(size: 100)
                        
                        Text("No investments yet")
                            .font(.headline)
                            .foregroundColor(.piggieText)
                        
                        Text("Start rounding up transactions to begin investing!")
                            .font(.subheadline)
                            .foregroundColor(.piggieTextLight)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Investing")
            .onAppear {
                loadPortfolio()
            }
        }
    }
    
    private var filteredChartData: [(Date, Int)] {
        switch selectedTimeframe {
        case .today:
            return chartData.filter { Calendar.current.isDateInToday($0.0) }
        case .allTime:
            return chartData
        }
    }
    
    private func loadPortfolio() {
        isLoading = true
        
        Task {
            do {
                let fetched: PortfolioSummary = try await APIClient.shared.request(endpoint: "/wallet/portfolio")
                
                // Generate chart data (simplified - in production, fetch from backend)
                let baseValue = fetched.current_value_cents
                var data: [(Date, Int)] = []
                let calendar = Calendar.current
                
                for i in 0..<30 {
                    if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                        // Simulate historical values
                        let variation = Int(Double(baseValue) * Double.random(in: -0.1...0.1))
                        data.append((date, baseValue + variation))
                    }
                }
                
                data.sort { $0.0 < $1.0 }
                
                await MainActor.run {
                    portfolio = fetched
                    chartData = data
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
