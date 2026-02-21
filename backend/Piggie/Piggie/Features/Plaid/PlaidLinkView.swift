import SwiftUI
// Note: In a real implementation, you would import LinkKit from Plaid
// For now, this is a placeholder that shows the flow

struct PlaidLinkView: View {
    @Binding var isPresented: Bool
    let onSuccess: () -> Void
    @State private var linkToken: String?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.piggieCream.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .piggieSage))
                        Text("Preparing connection...")
                            .foregroundColor(.piggieTextLight)
                    } else if let token = linkToken {
                        // In a real implementation, you would present Plaid Link here
                        // For now, show a mock interface
                        PlaidLinkMockView(linkToken: token, onSuccess: {
                            isPresented = false
                            onSuccess()
                        })
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Connection Error")
                                .font(.headline)
                                .foregroundColor(.piggieText)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.piggieTextLight)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if error.contains("not configured") || error.contains("503") || error.contains("Plaid") {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Plaid credentials are required:")
                                        .font(.caption)
                                        .foregroundColor(.piggieTextLight)
                                    
                                    Text("1. Get sandbox credentials from dashboard.plaid.com")
                                        .font(.caption2)
                                        .foregroundColor(.piggieTextLight)
                                    
                                    Text("2. Add PLAID_CLIENT_ID and PLAID_SECRET to backend/.env")
                                        .font(.caption2)
                                        .foregroundColor(.piggieTextLight)
                                    
                                    Text("3. Restart the backend server")
                                        .font(.caption2)
                                        .foregroundColor(.piggieTextLight)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            
                            Button("Try Again") {
                                loadLinkToken()
                            }
                            .buttonStyle(PiggieButtonStyle())
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Connect Bank")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                loadLinkToken()
            }
        }
    }
    
    private func loadLinkToken() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                struct LinkTokenResponse: Decodable {
                    let link_token: String
                }
                
                let response: LinkTokenResponse = try await APIClient.shared.request(
                    endpoint: "/plaid/link_token",
                    method: .POST
                )
                
                await MainActor.run {
                    linkToken = response.link_token
                    isLoading = false
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

// Mock Plaid Link view for demonstration
// In production, replace this with actual Plaid LinkKit integration
struct PlaidLinkMockView: View {
    let linkToken: String
    let onSuccess: () -> Void
    @State private var username = ""
    @State private var password = ""
    @State private var isConnecting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Plaid Link (Sandbox)")
                .font(.headline)
            
            Text("Use test credentials:")
                .font(.subheadline)
                .foregroundColor(.piggieTextLight)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Username: user_good")
                    .font(.caption)
                    .foregroundColor(.piggieText)
                
                Text("Password: pass_good")
                    .font(.caption)
                    .foregroundColor(.piggieText)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            TextField("Username", text: $username)
                .textFieldStyle(PiggieTextFieldStyle())
                .textContentType(.username)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(PiggieTextFieldStyle())
                .textContentType(.password)
            
            Button(action: connect) {
                if isConnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Connect")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PiggieButtonStyle())
            .disabled(isConnecting)
        }
        .padding()
    }
    
    private func connect() {
        isConnecting = true
        
        // In production, this would be handled by Plaid LinkKit
        // For now, simulate the flow
        Task {
            // Simulate Plaid Link success
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Exchange public token (mock)
            do {
                struct ExchangeRequest: Encodable {
                    let public_token: String
                }
                
                struct ExchangeResponse: Decodable {
                    let status: String
                }
                
                // In real implementation, Plaid Link would provide public_token
                // For mock, we'll use a placeholder
                let _: ExchangeResponse = try await APIClient.shared.request(
                    endpoint: "/plaid/exchange_public_token",
                    method: .POST,
                    body: ExchangeRequest(public_token: "mock_public_token_\(linkToken)")
                )
                
                await MainActor.run {
                    isConnecting = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isConnecting = false
                }
            }
        }
    }
}
