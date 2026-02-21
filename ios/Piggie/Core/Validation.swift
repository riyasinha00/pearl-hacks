import Foundation

struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?
}

class Validator {
    static let shared = Validator()
    
    private init() {}
    
    func validateEmail(_ email: String) -> ValidationResult {
        if email.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Email is required")
        }
        
        let trimmed = email.trimmingCharacters(in: .whitespaces).lowercased()
        let pattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        
        if regex.firstMatch(in: trimmed, range: range) == nil {
            return ValidationResult(isValid: false, errorMessage: "Please enter a valid email address")
        }
        
        if trimmed.count > 254 {
            return ValidationResult(isValid: false, errorMessage: "Email address is too long")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validateName(_ name: String) -> ValidationResult {
        if name.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Name is required")
        }
        
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        
        if trimmed.count < 2 {
            return ValidationResult(isValid: false, errorMessage: "Name must be at least 2 characters")
        }
        
        if trimmed.count > 40 {
            return ValidationResult(isValid: false, errorMessage: "Name must be no more than 40 characters")
        }
        
        let pattern = #"^[a-zA-Z\s\-\']+$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        
        if regex.firstMatch(in: trimmed, range: range) == nil {
            return ValidationResult(isValid: false, errorMessage: "Name can only contain letters, spaces, hyphens, and apostrophes")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validateSchool(_ school: String) -> ValidationResult {
        if school.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "School is required")
        }
        
        let trimmed = school.trimmingCharacters(in: .whitespaces)
        
        if trimmed.count < 2 {
            return ValidationResult(isValid: false, errorMessage: "School name must be at least 2 characters")
        }
        
        if trimmed.count > 60 {
            return ValidationResult(isValid: false, errorMessage: "School name must be no more than 60 characters")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validateGradYear(_ year: Int) -> ValidationResult {
        let currentYear = Calendar.current.component(.year, from: Date())
        let minYear = currentYear - 10
        let maxYear = currentYear + 10
        
        if year < minYear || year > maxYear {
            return ValidationResult(isValid: false, errorMessage: "Graduation year must be between \(minYear) and \(maxYear)")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validateMonthlyGoal(_ amount: Double) -> ValidationResult {
        if amount < 0 {
            return ValidationResult(isValid: false, errorMessage: "Monthly goal must be positive")
        }
        
        if amount > 5000 {
            return ValidationResult(isValid: false, errorMessage: "Monthly goal cannot exceed $5,000")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Password is required")
        }
        
        if password.count < 10 {
            return ValidationResult(isValid: false, errorMessage: "Password must be at least 10 characters")
        }
        
        if password.count > 72 {
            return ValidationResult(isValid: false, errorMessage: "Password must be no more than 72 characters")
        }
        
        let hasUpperCase = password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
        let hasLowerCase = password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
        let hasSymbol = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?")) != nil
        
        if !hasUpperCase {
            return ValidationResult(isValid: false, errorMessage: "Password must include at least one uppercase letter")
        }
        
        if !hasLowerCase {
            return ValidationResult(isValid: false, errorMessage: "Password must include at least one lowercase letter")
        }
        
        if !hasDigit {
            return ValidationResult(isValid: false, errorMessage: "Password must include at least one number")
        }
        
        if !hasSymbol {
            return ValidationResult(isValid: false, errorMessage: "Password must include at least one symbol")
        }
        
        let commonPasswords = ["password", "1234567890", "qwerty", "qwerty123", "password123"]
        if commonPasswords.contains(password.lowercased()) {
            return ValidationResult(isValid: false, errorMessage: "This password is too common. Please choose a stronger password")
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
}
