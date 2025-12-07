//
//  UserDataManager.swift
//  Noiseless
//
//  Created for persistent user data storage
//

import Foundation

/// Manager for persisting and retrieving user onboarding data
class UserDataManager {
    static let shared = UserDataManager()

    private let userDataKey = "savedUserData"
    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Local Storage (UserDefaults)

    /// Save user data to local storage as JSON
    func saveUserDataLocally(_ userData: UserData) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(userData)
        userDefaults.set(jsonData, forKey: userDataKey)
        userDefaults.synchronize()

        // Also save as readable JSON string for debugging
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Saved user data:\n\(jsonString)")
        }
    }

    /// Retrieve user data from local storage
    func loadUserDataLocally() throws -> UserData? {
        guard let jsonData = userDefaults.data(forKey: userDataKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let userData = try decoder.decode(UserData.self, from: jsonData)
        return userData
    }

    /// Check if user data exists locally
    func hasLocalUserData() -> Bool {
        return userDefaults.data(forKey: userDataKey) != nil
    }

    /// Clear all stored user data
    func clearUserData() {
        userDefaults.removeObject(forKey: userDataKey)
        userDefaults.synchronize()
    }

    /// Export user data as JSON string
    func exportUserDataAsJSON() throws -> String? {
        guard let userData = try loadUserDataLocally() else {
            return nil
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(userData)
        return String(data: jsonData, encoding: .utf8)
    }

    // MARK: - Backend Storage

    /// Save user data to backend API
    func saveUserDataToBackend(_ userData: UserData, authController: AuthController) async throws -> Bool {
        guard let url = URL(string: "\(NoiselessAPIService.baseURL)/v1/user/profile/update") else {
            throw UserDataError.invalidURL
        }

        // Get access token
        guard let accessToken = await authController.getAccessToken() else {
            throw UserDataError.authenticationRequired
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        request.httpBody = try encoder.encode(userData)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserDataError.invalidResponse
        }

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            // Parse response to confirm success
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = jsonResponse["success"] as? Bool {
                return success
            }
            return true
        } else {
            throw UserDataError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    /// Retrieve user data from backend API
    func fetchUserDataFromBackend() async throws -> UserData {
        guard let url = URL(string: "\(NoiselessAPIService.baseURL)/user-data") else {
            throw UserDataError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserDataError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw UserDataError.serverError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let userData = try decoder.decode(UserData.self, from: data)
        return userData
    }

    // MARK: - Complete Save (Local + Backend)

    /// Save user data both locally and to backend
    func saveUserDataComplete(_ userData: UserData, authController: AuthController) async throws {
        // First save locally for immediate access
        try saveUserDataLocally(userData)

        // Then attempt to save to backend
        do {
            let success = try await saveUserDataToBackend(userData, authController: authController)
            if success {
                print("User data successfully saved to backend")
            }
        } catch {
            print("Warning: Failed to save to backend, but local save succeeded: \(error)")
            // Don't throw - local save succeeded
        }
    }
}

// MARK: - Error Types

enum UserDataError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case encodingError
    case decodingError
    case authenticationRequired

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error (Status: \(code))"
        case .encodingError:
            return "Failed to encode user data"
        case .decodingError:
            return "Failed to decode user data"
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}
