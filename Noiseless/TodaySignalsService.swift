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

// MARK: - Today Signals Service

enum TodaySignalsService {
    static func fetchTodaySignals() async throws -> [SignalItem] {
        guard let url = URL(string: "\(NoiselessAPIService.baseURL)/today-signals") else {
            throw ServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        // Debug: Print raw response
        #if DEBUG
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("Today Signals API Response: \(rawResponse)")
        }
        #endif

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ServiceError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(TodaySignalsResponse.self, from: data)

        // Convert DTOs to SignalItems
        return apiResponse.todaySignals.map { $0.toSignalItem() }
    }
}

// MARK: - Service Errors

enum ServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(String)

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
        }
    }
}
