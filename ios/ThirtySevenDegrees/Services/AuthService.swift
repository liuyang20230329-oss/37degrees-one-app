import Foundation

@Observable
final class AuthService {
    static let shared = AuthService()

    var token: String?
    var currentUser: User?

    private let tokenKey = "auth_token"
    private let userKey = "auth_user"
    private let defaults = UserDefaults.standard

    var isAuthenticated: Bool { token != nil }

    private init() {
        loadSession()
    }

    func saveSession(token: String, user: User) {
        self.token = token
        self.currentUser = user
        defaults.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            defaults.set(userData, forKey: userKey)
        }
    }

    func clearSession() {
        token = nil
        currentUser = nil
        defaults.removeObject(forKey: tokenKey)
        defaults.removeObject(forKey: userKey)
    }

    func updateUser(_ user: User) {
        self.currentUser = user
        if let userData = try? JSONEncoder().encode(user) {
            defaults.set(userData, forKey: userKey)
        }
    }

    private func loadSession() {
        token = defaults.string(forKey: tokenKey)
        if let userData = defaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }
}
