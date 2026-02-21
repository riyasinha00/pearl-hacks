import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.piggieText)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(PiggieTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: email) { _ in
                        validateEmail()
                    }
                
                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(.piggieText)
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(PiggieTextFieldStyle())
                    .textContentType(.password)
                    .onChange(of: password) { _ in
                        validatePassword()
                    }
                
                if let error = passwordError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PiggieButtonStyle())
            .disabled(!isFormValid || isLoading)
        }
        .padding()
    }
    
    private var isFormValid: Bool {
        emailError == nil && passwordError == nil && !email.isEmpty && !password.isEmpty
    }
    
    private func validateEmail() {
        let result = Validator.shared.validateEmail(email)
        emailError = result.isValid ? nil : result.errorMessage
    }
    
    private func validatePassword() {
        passwordError = nil // Password validation on login is less strict
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                struct LoginRequest: Encodable {
                    let email: String
                    let password: String
                }
                
                struct TokenResponse: Decodable {
                    let access_token: String
                }
                
                let response: TokenResponse = try await APIClient.shared.request(
                    endpoint: "/auth/login",
                    method: .POST,
                    body: LoginRequest(email: email.trimmingCharacters(in: .whitespaces).lowercased(), password: password)
                )
                
                await MainActor.run {
                    authManager.login(token: response.access_token)
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
