import UIKit

public extension String {
    static let fileFormat = ".png"
}

public extension CGFloat {
    static let contentDivider: CGFloat = 6 // divide screen.width for models
    static let maxContentDivider: CGFloat = 10 // maximum divide screen.width for random apex size
    static let paddingBottomPlayerMultiplyer: CGFloat = 2.8 // bottom player padding = x * model.height
    static let playerMovementDivider: CGFloat = 3.2 // movement = model.width / x
}

public extension Double {
    static let defaultSpeedMultiplyer = 1.0 // start speed
    static let speedMultiplyer = 0.95 // multiply speed by take() boost in game NOTE: < 1
    static let sizeWhileJumping = 1.5 // player model size while jumping
    static let rotatePlayerDegree = 25.0 // player rotating degree if move left/right
}

public extension Int {
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

public extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 60 // framerate
    //  spawnrates
    static let apexSpawnRate: TimeInterval = 3.2
    static let jumpBoardSpawnRate: TimeInterval = 6.5
    static let coinsSpawnRate: TimeInterval = 1.5
    static let boostSpawnRate: TimeInterval = 10
    // -- // --
    static let movementTime: TimeInterval = 5.8 // base movement time for objects
    static let defaultJumpDuration: TimeInterval = 1.15  // player jump duration
}
