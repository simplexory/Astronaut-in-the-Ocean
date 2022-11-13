import Foundation
import UIKit

extension CGFloat {
    static let contentDivider: CGFloat = 6
    static let maxContentDivider: CGFloat = 10
    static let paddingBottomAstronautMultiplyer: CGFloat = 2.8
}

extension Double {
    static let defaultMultiplyer = 1.0
}

extension Int {
    static let apexObjectsCount = 12
    static let jumpBoardObjectsCount = 5
    static let coinObjectCount = 20
    static let startScore = 0
    static let defaultScoreMultiplyer = 1
    static let scorePerCoin = 5
}

extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 61
    static let apexSpawnRate: TimeInterval = 2.5
    static let jumpBoardSpawnRate: TimeInterval = 6
    static let coinsSpawnRate: TimeInterval = 1.5
    static let movementTime: TimeInterval = 6
    static let defaultJumpDuration: TimeInterval = 1.15
}
