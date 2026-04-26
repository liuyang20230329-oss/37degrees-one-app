import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var email: String?
    var phoneNumber: String?
    var maskedPhoneNumber: String?
    var avatarKey: String?
    var gender: Gender
    var birthYear: Int?
    var birthMonth: Int?
    var city: String?
    var signature: String?
    var introVideoTitle: String?
    var introVideoSummary: String?
    var phoneStatus: VerificationStatus
    var identityStatus: VerificationStatus
    var faceStatus: VerificationStatus
    var legalName: String?
    var maskedIdNumber: String?
    var faceMatchScore: Double?
    var membershipLevel: MembershipLevel
    var isOnline: Bool
    var activityScore: Int?
    var works: [Work]

    enum Gender: String, Codable, CaseIterable {
        case undisclosed = "undisclosed"
        case male = "male"
        case female = "female"

        var displayName: String {
            switch self {
            case .undisclosed: return "未设置"
            case .male: return "男"
            case .female: return "女"
            }
        }
    }

    enum VerificationStatus: String, Codable {
        case none = "none"
        case pending = "pending"
        case verified = "verified"
        case rejected = "rejected"

        var isVerified: Bool { self == .verified }
    }

    enum MembershipLevel: String, Codable {
        case standard = "standard"
        case premium = "premium"
        case vip = "vip"
    }

    struct Work: Codable, Identifiable, Equatable {
        let id: String
        var type: WorkType
        var title: String
        var summary: String?
        var mediaUrl: String?
        var duration: Int?
        var isPinned: Bool

        enum WorkType: String, Codable {
            case voice
            case video
            case image
        }
    }

    var profileCompletion: Double {
        var filled = 0
        let total = 6
        if !name.isEmpty { filled += 1 }
        if gender != .undisclosed { filled += 1 }
        if birthYear != nil { filled += 1 }
        if city != nil && !(city?.isEmpty ?? true) { filled += 1 }
        if signature != nil && !(signature?.isEmpty ?? true) { filled += 1 }
        if avatarKey != nil { filled += 1 }
        return Double(filled) / Double(total)
    }

    var verificationCompletion: Double {
        var verified = 0
        let total = 3
        if phoneStatus.isVerified { verified += 1 }
        if identityStatus.isVerified { verified += 1 }
        if faceStatus.isVerified { verified += 1 }
        return Double(verified) / Double(total)
    }
}
