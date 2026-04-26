import SwiftUI

@main
struct ThirtySevenDegreesApp: App {
    @State private var authService = AuthService.shared

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                AuthView(onLoginSuccess: { authService.isAuthenticated = true })
            }
        }
    }
}
