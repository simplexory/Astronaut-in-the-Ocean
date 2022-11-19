import UIKit

public extension CGFloat {
    static let contentDivider: CGFloat = 6 // divide screen.width for models
    static let maxContentDivider: CGFloat = 10 // maximum divide screen.width for random apex size
    static let paddingBottomPlayerMultiplyer: CGFloat = 2.8 // bottom player padding x * model.height
    static let playerMovementDivider: CGFloat = 3.2 // movement = model.width / x
}

public extension Double {
    static let defaultSpeedMultiplyer = 1.0 // start speed
    static let speedMultiplyer = 0.93 // multiply speed by take() boost in game
    static let sizeWhileJumping = 1.5 // player model size while jumping
    static let rotatePlayerDegree = 25.0 // player rotating degree if move left/right
}

public extension Int {
    // counter for objects
    static let apexObjectsCount = 18
    static let boostObjectsCount = 3
    static let jumpBoardObjectsCount = 5
    static let coinObjectCount = 24
    // --  // ---
    static let startScore = 0
    static let defaultScoreMultiplyer = 1
    static let scorePerCoin = 5 // score per 1 coin in game
}

public extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 60 // framerate timer
    //  spawnrates
    static let apexSpawnRate: TimeInterval = 3.2
    static let jumpBoardSpawnRate: TimeInterval = 6.5
    static let coinsSpawnRate: TimeInterval = 1.5
    static let boostSpawnRate: TimeInterval = 10
    // -- // --
    static let movementTime: TimeInterval = 5.8 // base movement time for objects
    static let defaultJumpDuration: TimeInterval = 1.15  // player jump duration
}
