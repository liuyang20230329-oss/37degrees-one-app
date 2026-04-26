import Foundation

@Observable
final class ProfileViewModel {
    var viewState: ViewState<User> = .loading
    var settings: UserSettings?
    var isUpdating = false
    var errorMessage: String?

    private let service = ProfileService.shared
    private let auth = AuthService.shared

    var user: User? {
        if case .success(let user) = viewState { return user }
        if case .refreshing(let user) = viewState { return user }
        return auth.currentUser
    }

    func loadProfile() async {
        viewState = .loading
        do {
            let user = try await service.fetchProfile()
            auth.updateUser(user)
            viewState = .success(user)
        } catch {
            if let local = auth.currentUser {
                viewState = .success(local)
            } else {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func refresh() async {
        guard let current = user else { return await loadProfile() }
        viewState = .refreshing(current)
        do {
            let updated = try await service.fetchProfile()
            auth.updateUser(updated)
            viewState = .success(updated)
        } catch {
            errorMessage = error.localizedDescription
            viewState = .success(current)
        }
    }

    func updateProfile(fields: [String: Any]) async -> Bool {
        isUpdating = true
        defer { isUpdating = false }
        do {
            let updated = try await service.updateProfile(fields: fields)
            auth.updateUser(updated)
            viewState = .success(updated)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func loadSettings() async {
        do {
            settings = try await service.fetchSettings()
        } catch {
            settings = UserSettings(friendsOnly: false, allowSquareExposure: true, preferVerifiedUsers: true)
        }
    }

    func saveSettings(_ newSettings: UserSettings) async {
        do {
            let saved = try await service.updateSettings(newSettings)
            settings = saved
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteWork(workId: String) async {
        do {
            try await service.deleteWork(workId: workId)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
