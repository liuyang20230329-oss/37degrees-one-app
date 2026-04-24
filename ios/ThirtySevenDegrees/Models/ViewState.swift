import SwiftUI

enum ViewState<T> {
    case loading
    case success(T)
    case empty
    case error(String)
    case refreshing(T)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
