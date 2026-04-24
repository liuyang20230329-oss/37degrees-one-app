import SwiftUI

@main
struct ThirtySevenDegreesApp: App {
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
            } else {
                AuthView(onLoginSuccess: { isLoggedIn = true })
            }
        }
    }
}
