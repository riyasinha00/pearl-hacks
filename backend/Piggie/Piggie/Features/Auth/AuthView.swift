import SwiftUI

struct AuthView: View {
    @State private var isSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    PiggieMascot(size: 120, bounce: true)
                        .padding(.top, 40)
                    
                    Text("Welcome to Piggie!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.piggieText)
                    
                    if isSignUp {
                        SignUpView()
                    } else {
                        LoginView()
                    }
                    
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Log in" : "Don't have an account? Sign up")
                            .foregroundColor(.piggieSage)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
    }
}
