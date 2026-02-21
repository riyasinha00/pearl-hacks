import SwiftUI

struct SignUpView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var school = ""
    @State private var gradYear = Calendar.current.component(.year, from: Date())
    @State private var monthlyGoal: Double = 100
    
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var schoolError: String?
    @State private var gradYearError: String?
    @State private var monthlyGoalError: String?
    
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("School")
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    TextField("Enter your school", text: $school)
                        .textFieldStyle(PiggieTextFieldStyle())
                        .onChange(of: school) { _ in
                            validateSchool()
                        }
                    
                    if let error = schoolError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Graduation Year")
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    Picker("Graduation Year", selection: $gradYear) {
                        ForEach(availableGradYears, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: gradYear) { _ in
                        validateGradYear()
                    }
                    
                    if let error = gradYearError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Goal: $\(Int(monthlyGoal))")
                        .font(.headline)
                        .foregroundColor(.piggieText)
                    
                    Slider(value: $monthlyGoal, in: 0...5000, step: 10)
                        .tint(.piggieSage)
                        .onChange(of: monthlyGoal) { _ in
                            validateMonthlyGoal()
                        }
                    
                    if let error = monthlyGoalError {
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
    
    private var availableGradYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 10)...(currentYear + 10))
    }
    
    private var isFormValid: Bool {
        nameError == nil && emailError == nil && passwordError == nil &&
        schoolError == nil && gradYearError == nil && monthlyGoalError == nil &&
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !school.isEmpty
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
    
    private func validateSchool() {
        let result = Validator.shared.validateSchool(school)
        schoolError = result.isValid ? nil : result.errorMessage
    }
    
    private func validateGradYear() {
        let result = Validator.shared.validateGradYear(gradYear)
        gradYearError = result.isValid ? nil : result.errorMessage
    }
    
    private func validateMonthlyGoal() {
        let result = Validator.shared.validateMonthlyGoal(monthlyGoal)
        monthlyGoalError = result.isValid ? nil : result.errorMessage
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                struct SignUpRequest: Encodable {
                    let name: String
                    let email: String
                    let password: String
                    let school: String
                    let grad_year: Int
                    let monthly_goal: Double
                }
                
                struct TokenResponse: Decodable {
                    let access_token: String
                }
                
                let response: TokenResponse = try await APIClient.shared.request(
                    endpoint: "/auth/signup",
                    method: .POST,
                    body: SignUpRequest(
                        name: name.trimmingCharacters(in: .whitespaces),
                        email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                        password: password,
                        school: school.trimmingCharacters(in: .whitespaces),
                        grad_year: gradYear,
                        monthly_goal: monthlyGoal
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
