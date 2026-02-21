import SwiftUI

struct PiggieTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PiggieButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.piggieSage, Color.piggieSage.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.piggieSage.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PiggieCard: View {
    var content: () -> AnyView
    
    init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        content()
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

struct CurrencyText: View {
    let cents: Int
    var font: Font = .title2
    var fontWeight: Font.Weight = .semibold
    
    var body: some View {
        Text(formatCurrency(cents))
            .font(font)
            .fontWeight(fontWeight)
            .foregroundColor(.piggieText)
    }
    
    private func formatCurrency(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: dollars)) ?? "$0.00"
    }
}
