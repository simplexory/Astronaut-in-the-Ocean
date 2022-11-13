import Foundation
import UIKit

extension CGFloat {
    static let contentDivider: CGFloat = 6
    static let maxContentDivider: CGFloat = 10
    static let paddingBottomAstronautMultiplyer: CGFloat = 2.8
}

extension Double {
    static let defaultSpeedMultiplyer = 1.0
    static let speedMultiplyer = 0.9
}

extension Int {
    static let apexObjectsCount = 18
    static let boostObjectsCount = 3
    static let jumpBoardObjectsCount = 5
    static let coinObjectCount = 24
    static let startScore = 0
    static let defaultScoreMultiplyer = 1
    static let scorePerCoin = 5
}

extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 61
    static let apexSpawnRate: TimeInterval = 3.2
    static let jumpBoardSpawnRate: TimeInterval = 6.5
    static let coinsSpawnRate: TimeInterval = 1.5
    static let boostSpawnRate: TimeInterval = 10
    static let movementTime: TimeInterval = 5.8
    static let defaultJumpDuration: TimeInterval = 1.15
}
