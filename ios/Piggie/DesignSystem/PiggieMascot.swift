import SwiftUI

struct PiggieMascot: View {
    var size: CGFloat = 100
    var bounce: Bool = false
    
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Body (pink circle)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.piggiePink, Color.piggiePink.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .offset(y: bounceOffset)
            
            // Ears
            HStack(spacing: size * 0.5) {
                Ellipse()
                    .fill(Color.piggiePink)
                    .frame(width: size * 0.25, height: size * 0.3)
                    .rotationEffect(.degrees(-20))
                
                Ellipse()
                    .fill(Color.piggiePink)
                    .frame(width: size * 0.25, height: size * 0.3)
                    .rotationEffect(.degrees(20))
            }
            .offset(y: -size * 0.35 + bounceOffset)
            
            // Eyes
            HStack(spacing: size * 0.15) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.15, height: size * 0.15)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.08, height: size * 0.08)
                            .offset(x: size * 0.02, y: -size * 0.01)
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.15, height: size * 0.15)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.08, height: size * 0.08)
                            .offset(x: size * 0.02, y: -size * 0.01)
                    )
            }
            .offset(y: -size * 0.05 + bounceOffset)
            
            // Nose
            Ellipse()
                .fill(Color.piggiePink.opacity(0.7))
                .frame(width: size * 0.12, height: size * 0.1)
                .offset(y: size * 0.05 + bounceOffset)
            
            // Nostrils
            HStack(spacing: size * 0.04) {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: size * 0.03, height: size * 0.03)
                
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: size * 0.03, height: size * 0.03)
            }
            .offset(y: size * 0.05 + bounceOffset)
            
            // Smile
            Path { path in
                path.addArc(
                    center: CGPoint(x: 0, y: size * 0.15),
                    radius: size * 0.12,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false
                )
            }
            .stroke(Color.black.opacity(0.3), lineWidth: 2)
            .offset(y: bounceOffset)
        }
        .frame(width: size, height: size)
        .onAppear {
            if bounce {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    bounceOffset = -5
                }
            }
        }
    }
}

#Preview {
    PiggieMascot(size: 150, bounce: true)
        .padding()
}
