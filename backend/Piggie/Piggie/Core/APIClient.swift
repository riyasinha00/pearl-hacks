import Foundation

class APIClient {
    static let shared = APIClient()
    
    // Update this to your backend URL
    // For simulator: http://localhost:8000
    // For physical device: http://<your-computer-ip>:8000
    private let baseURL = "http://localhost:8000"
    
    private var accessToken: String? {
        get {
            KeychainHelper.shared.getToken()
        }
        set {
            if let token = newValue {
                KeychainHelper.shared.saveToken(token)
            } else {
                KeychainHelper.shared.deleteToken()
            }
        }
    }
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            // Token expired or invalid
            accessToken = nil
            NotificationCenter.default.post(name: .userLoggedOut, object: nil)
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorData.detail)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(T.self, from: data)
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case httpError(Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return message
        }
    }
}

struct ErrorResponse: Decodable {
    let detail: String
}

extension Notification.Name {
    static let userLoggedOut = Notification.Name("userLoggedOut")
}
