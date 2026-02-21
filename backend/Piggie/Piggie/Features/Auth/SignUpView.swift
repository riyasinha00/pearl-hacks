import SwiftUI

struct SignUpView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(PiggieTextFieldStyle())
                        .textContentType(.name)
                        .onChange(of: name) { _ in
                            validateName()
                        }
                    
                    if let error = nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
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
                        .textContentType(.newPassword)
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
                
                Button(action: signUp) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PiggieButtonStyle())
                .disabled(!isFormValid || isLoading)
            }
            .padding()
        }
    }
    
    private var isFormValid: Bool {
        nameError == nil && emailError == nil && passwordError == nil &&
        !name.isEmpty && !email.isEmpty && !password.isEmpty
    }
    
    private func validateName() {
        let result = Validator.shared.validateName(name)
        nameError = result.isValid ? nil : result.errorMessage
    }
    
    private func validateEmail() {
        let result = Validator.shared.validateEmail(email)
        emailError = result.isValid ? nil : result.errorMessage
    }
    
    private func validatePassword() {
        let result = Validator.shared.validatePassword(password)
        passwordError = result.isValid ? nil : result.errorMessage
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                struct SignUpRequest: Encodable {
                    let full_name: String // Change 'name' to 'full_name'
                    let email: String
                    let password: String
                }
                
                struct TokenResponse: Decodable {
                    let access_token: String
                }
                
                let response: TokenResponse = try await APIClient.shared.request(
                    endpoint: "/auth/signup",
                    method: .POST,
                    body: SignUpRequest(
                        full_name: name.trimmingCharacters(in: .whitespaces),
                        email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                        password: password
                    )
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
