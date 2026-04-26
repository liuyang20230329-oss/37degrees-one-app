import Foundation

actor ProfileService {
    static let shared = ProfileService()

    private let baseURL: String
    private let session = URLSession.shared

    init() {
        let env = ProcessInfo.processInfo.environment
        self.baseURL = env["LOCAL_API_BASE_URL"] ?? "http://127.0.0.1:3001"
    }

    private func authHeaders() -> [String: String]? {
        guard let token = AuthService.shared.token else { return nil }
        return ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
    }

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/api/v1\(path)") else {
            throw ProfileError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let headers = authHeaders() {
            for (key, value) in headers { request.setValue(value, forHTTPHeaderField: key) }
        }
        if let body { request.httpBody = body }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw ProfileError.invalidResponse }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorJson["error"] as? String {
                throw ProfileError.serverError(message)
            }
            throw ProfileError.httpError(httpResponse.statusCode)
        }
        return data
    }

    func fetchProfile() async throws -> User {
        let data = try await makeRequest(path: "/users/me/complete")
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let userDict = json["user"] as? [String: Any] {
            let userData = try JSONSerialization.data(withJSONObject: userDict)
            return try JSONDecoder().decode(User.self, from: userData)
        }
        return try JSONDecoder().decode(User.self, from: data)
    }

    func updateProfile(fields: [String: Any]) async throws -> User {
        let body = try JSONSerialization.data(withJSONObject: fields)
        let data = try await makeRequest(path: "/users/me/profile", method: "PUT", body: body)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let userDict = json["user"] as? [String: Any] {
            let userData = try JSONSerialization.data(withJSONObject: userDict)
            return try JSONDecoder().decode(User.self, from: userData)
        }
        return try JSONDecoder().decode(User.self, from: data)
    }

    func fetchSettings() async throws -> UserSettings {
        let data = try await makeRequest(path: "/users/me/settings")
        return try JSONDecoder().decode(UserSettings.self, from: data)
    }

    func updateSettings(_ settings: UserSettings) async throws -> UserSettings {
        let body = try JSONSerialization.data(withJSONObject: settings.toDictionary())
        let data = try await makeRequest(path: "/users/me/settings", method: "PUT", body: body)
        return try JSONDecoder().decode(UserSettings.self, from: data)
    }

    func deleteWork(workId: String) async throws {
        _ = try await makeRequest(path: "/users/me/works/\(workId)", method: "DELETE")
    }
}

struct UserSettings: Codable {
    var friendsOnly: Bool
    var allowSquareExposure: Bool
    var preferVerifiedUsers: Bool

    func toDictionary() -> [String: Any] {
        [
            "friendsOnly": friendsOnly,
            "allowSquareExposure": allowSquareExposure,
            "preferVerifiedUsers": preferVerifiedUsers
        ]
    }
}

enum ProfileError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的请求地址"
        case .invalidResponse: return "无效的响应"
        case .httpError(let code): return "请求失败 (\(code))"
        case .serverError(let msg): return msg
        case .notAuthenticated: return "未登录"
        }
    }
}
