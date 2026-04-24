import SwiftUI

enum AppDuration: Double {
    case instant = 0.1
    case fast = 0.2
    case normal = 0.3
    case slow = 0.5
    case glacial = 0.8
}

extension Animation {
    static let appInstant = Animation.easeInOut(duration: AppDuration.instant.rawValue)
    static let appFast = Animation.easeInOut(duration: AppDuration.fast.rawValue)
    static let appNormal = Animation.easeInOut(duration: AppDuration.normal.rawValue)
    static let appSlow = Animation.easeInOut(duration: AppDuration.slow.rawValue)
    static let appGlacial = Animation.easeInOut(duration: AppDuration.glacial.rawValue)

    static let appDecelerate = Animation.easeOut(duration: AppDuration.normal.rawValue)
    static let appAccelerate = Animation.easeIn(duration: AppDuration.normal.rawValue)
    static let appSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
}
