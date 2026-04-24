import SwiftUI

extension CGFloat {
    static let spaceNone: CGFloat = 0
    static let spaceXXS: CGFloat = 2
    static let spaceXS: CGFloat = 4
    static let spaceSM: CGFloat = 8
    static let spaceMD: CGFloat = 12
    static let spaceLG: CGFloat = 16
    static let spaceXL: CGFloat = 20
    static let spaceXXL: CGFloat = 24
    static let spaceXXXL: CGFloat = 32
}

extension EdgeInsets {
    static let pageHorizontal = EdgeInsets(top: 0, leading: .spaceLG, bottom: 0, trailing: .spaceLG)
    static let cardPadding = EdgeInsets(top: .spaceMD, leading: .spaceLG, bottom: .spaceMD, trailing: .spaceLG)
}
