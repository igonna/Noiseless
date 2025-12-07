import Foundation

// MARK: - API Response Models

struct TodaySignalsResponse: Codable {
    let todaySignals: [TodaySignalDTO]

    enum CodingKeys: String, CodingKey {
        case todaySignals = "today-signals"
    }
}

struct TodaySignalDTO: Codable {
    let id: String
    let type: String
    let name: String
    let content: String
    let actionType: String
    let actionName: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case content
        case actionType = "action-type"
        case actionName = "action-name"
        case createdAt = "created_at"
    }

    // Convert DTO to SignalItem
    func toSignalItem() -> SignalItem {
        // Map API type to internal type format
        let internalType = mapTypeToInternal(type)

        return SignalItem(
            id: id,
            type: internalType,
            title: name,
            description: content,
            action: actionName
        )
    }

    private func mapTypeToInternal(_ apiType: String) -> String {
        // Map API types to internal types used by the UI
        switch apiType.uppercased() {
        case "WORLD SHIFT":
            return "shift"
        case "NEWS ESSENCE":
            return "news_essence"
        case "OPPORTUNITY WINDOW", "OPPORTUNITY":
            return "opportunity"
        case "WHAT'S HOT (24H)", "HYPE HOT":
            return "hype_hot"
        case "MICRO-CHALLENGE":
            return "micro_challenge"
        case "ECOSYSTEM SHORTCUT":
            return "shortcut"
        case "MENTAL MODEL":
            return "mental_model"
        default:
            return "shift" // default fallback
        }
    }
}

// MARK: - Signal Action Models

struct SignalActionRequest: Codable {
    let signalId: String

    enum CodingKeys: String, CodingKey {
        case signalId = "signal_id"
    }
}

struct SignalActionResponse: Codable {
    let actionResult: String

    enum CodingKeys: String, CodingKey {
        case actionResult = "action-result"
    }
}

// MARK: - Today Signals Service

enum TodaySignalsService {
    static func fetchTodaySignals(authController: AuthController) async throws -> [SignalItem] {
        let urlString = "\(NoiselessAPIService.baseURL)/v1/signal/today"
        print("🌐 Fetching today signals from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw ServiceError.invalidURL
        }

        // Get access token
        print("🔑 Requesting access token for today signals...")
        guard let accessToken = await authController.getAccessToken() else {
            print("❌ Failed to get access token for today signals")
            throw ServiceError.authenticationRequired
        }
        print("✅ Access token retrieved for today signals")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        print("📡 Sending GET request to \(url.absoluteString)...")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw ServiceError.invalidResponse
        }

        print("📨 Response status code: \(httpResponse.statusCode)")

        // Debug: Print raw response
        #if DEBUG
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("📥 Today Signals API Response: \(rawResponse)")
        }
        #endif

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Server error: Status \(httpResponse.statusCode), Message: \(errorMessage)")
            throw ServiceError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(TodaySignalsResponse.self, from: data)

        print("✅ Successfully fetched \(apiResponse.todaySignals.count) signals")
        // Convert DTOs to SignalItems
        return apiResponse.todaySignals.map { $0.toSignalItem() }
    }

    static func performSignalAction(signalId: String, authController: AuthController) async throws -> String {
        let urlString = "\(NoiselessAPIService.baseURL)/v1/signal/action"
        print("🌐 Performing signal action for signal ID: \(signalId)")
        print("🌐 Endpoint: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw ServiceError.invalidURL
        }

        // Get access token
        print("🔑 Requesting access token for signal action...")
        guard let accessToken = await authController.getAccessToken() else {
            print("❌ Failed to get access token for signal action")
            throw ServiceError.authenticationRequired
        }
        print("✅ Access token retrieved for signal action")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let requestBody = SignalActionRequest(signalId: signalId)
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)

        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
            print("📦 Request body: \(jsonString)")
        }

        print("📡 Sending POST request to \(url.absoluteString)...")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw ServiceError.invalidResponse
        }

        print("📨 Response status code: \(httpResponse.statusCode)")

        // Debug: Print raw response
        #if DEBUG
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("📥 Signal Action API Response: \(rawResponse)")
        }
        #endif

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Server error: Status \(httpResponse.statusCode), Message: \(errorMessage)")
            throw ServiceError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(SignalActionResponse.self, from: data)

        print("✅ Signal action completed successfully")
        return apiResponse.actionResult
    }
}

// MARK: - Service Errors

enum ServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(String)
    case authenticationRequired

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}
