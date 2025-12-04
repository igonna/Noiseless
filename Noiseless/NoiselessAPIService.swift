import Foundation

// MARK: - Noiseless API Service
// This file contains all API-related services for the Noiseless app

enum NoiselessAPIService {
    static let baseURL = "http://192.168.18.184:6469"

    // MARK: - API Endpoints

    /// POST /user-data - Save user onboarding data
    /// Request body: UserData (JSON)
    /// Response: { "success": true, "message": "User data saved successfully" }

    /// GET /user-data - Retrieve user onboarding data
    /// Response: UserData (JSON)

    // Add future API endpoints here as needed
    // Example: fetchFutureSignals(), fetchNextSteps(), etc.
}
