import UIKit

extension CGFloat {
    static let playerContentDivider: CGFloat = 6 // divide view.width for player size
    static let boosterContentDivider: CGFloat = 7.1 // divide view.width for booster size
    static let minApexContentDivider: CGFloat = 6.3 // divide view.width for apex size
    static let maxApexContentDivider: CGFloat = 8 // > minApexContentDivider
    static let coinContentDivider: CGFloat = 10.5 // divide view.width for coin size
    static let playerPaddingMultiplyer: CGFloat = 7.5 // bottom player padding = view / x
    static let playerMovementDivider: CGFloat = 1.6 // movement = model.width / x
}

extension Double {
    static let defaultSpeedMultiplyer = 1.0 // start speed
    static let speedMultiplyer = 0.95 // multiply speed by take() boost in game NOTE: < 1
    static let sizeWhileJumping = 2.5 // player model size while jumping
    static let rotatePlayerDegree = 25.0 // player rotating degree if move left/right
}

extension Int {
    // counter for objects
    static let apexObjectsCount = 8
    static let boostObjectsCount = 2
    static let jumpBoardObjectsCount = 3
    static let coinObjectCount = 10
    // Score
    static let startScore = 0
    static let defaultScoreMultiplyer = 1
    static let scorePerCoin = 5 // score per coin in game
}

extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 60 // framerate
    //  spawnrates
    static let apexSpawnRate: TimeInterval = 3.25
    static let jumpBoardSpawnRate: TimeInterval = 6.55
    static let coinsSpawnRate: TimeInterval = 1.53
    static let boostSpawnRate: TimeInterval = 10.1
    // -- // --
    static let movementTime: TimeInterval = 5.8 // base movement time for objects
    static let backgroundMovementTime: TimeInterval = 22.5 // base movement time for background
    static let defaultJumpDuration: TimeInterval = 1.15  // player jump duration
}
