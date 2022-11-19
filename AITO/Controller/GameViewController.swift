import UIKit

private extension CGFloat {
    static let constraintShowConstant: CGFloat = 15
    static let constraintHideConstant: CGFloat = -100
    static let buttonSize: CGFloat = 40
    static let scoreFontSize: CGFloat = 20
    static let gameOverFontSize: CGFloat = 30
}

private extension String {
    static let retryButtonText: String = "RETRY"
    static let menuButtonText: String = "MENU"
    static let scoreText: String = "Score:"
    static let gameOverText: String = "Game Over"
}

final class GameViewController: UIViewController {
    
    // MARK: var / let
    
    /** TODO:
     
            ADD BACKGROUND !
            ADD WATER COLISION WHILE PLAYER ON WATER
            ADD BETTER DESIGN BY IMAGES
     */
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var inGameScoreLabel: UILabel!
    @IBOutlet weak var inGameMultiplyerLabel: UILabel!
    @IBOutlet weak var gameStatusBottomConstraint: NSLayoutConstraint!
    
    private let player = Player()
    private var apexes: [GameObject] = []
    private var jumpBoards: [GameObject] = []
    private var coins: [GameObject] = []
    private var boosters: [GameObject] = []
    private var frameRateTimer = Timer()
    private var spawnApexTimer = Timer()
    private var spawnBoostTimer = Timer()
    private var spawnJumpBoardTimer = Timer()
    private var spawnCoinsTimer = Timer()
    private var speedMultiplyer: Double = .defaultSpeedMultiplyer
    private var scoreMultiplyer: Int = .defaultScoreMultiplyer
    private var gameInProgress = false
    private var score: Int = .startScore
    
    private var currentObjects: [GameObject] {
        get {
            var objects: [GameObject] = []
            objects.append(contentsOf: self.apexes.filter({ $0.isPresented }))
            objects.append(contentsOf: self.coins.filter({ $0.isPresented }))
            objects.append(contentsOf: self.jumpBoards.filter({ $0.isPresented }))
            objects.append(contentsOf: self.boosters.filter({ $0.isPresented }))
            return objects
        }
    }
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGestureRecognizer()
        self.setupObjects()
        self.setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startGame()
    }
    
    // MARK: setup model funcs
    
    private func setupPlayerModel() {
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        
        self.player.setup(viewWidth: viewWidth, viewHeight: viewHeight)
        self.view.addSubview(self.player.waterCollision)
        self.view.addSubview(self.player.model)
    }
    
    private func setupGameObjects() {
        let maxY = self.view.frame.height
        let maxX = self.view.frame.width
        // setup apexes
        for _ in 0..<Int.apexObjectsCount {
            let apexSize: CGFloat = self.view.frame.width / .random(in: .contentDivider...CGFloat.maxContentDivider)
            let apex = Apex(size: apexSize, maxY: maxY, maxX: maxX)
            
            self.apexes.append(apex)
            self.view.addSubview(apex.model)
        }
        //setup coins
        let coinSize: CGFloat = self.view.frame.width / .maxContentDivider
        for _ in 0..<Int.coinObjectCount {
            let coin = Coin(size: coinSize, maxY: maxY, maxX: maxX)
            
            self.coins.append(coin)
            self.view.addSubview(coin.model)
        }
        // setup boosters
        let boosterSize = self.view.frame.width / CGFloat.contentDivider
        for _ in 0..<Int.apexObjectsCount {
            let boost = Boost(size: boosterSize, maxY: maxY, maxX: maxX)

            self.boosters.append(boost)
            self.view.addSubview(boost.model)
        }
        // setup jump boards
        for _ in 0..<Int.jumpBoardObjectsCount {
            let jumpBoard = JumpBoard(size: coinSize, maxY: maxY, maxX: maxX)
            
            self.jumpBoards.append(jumpBoard)
            self.view.addSubview(jumpBoard.model)
        }
    }
    
    //MARK: intersections block
    
    private func checkPlayerIntersections() {
        guard let playerLayer = self.player.model.layer.presentation() else { return }
        if !player.inCorrectPosition() && !self.player.isJumpingNow { self.gameOver() }
        
        for object in currentObjects {
            guard let objectFrame = object.frame else { break }
            
            if objectFrame.intersects(playerLayer.frame) {
                if self.player.isJumpingNow == false {
                    if object is Apex { self.gameOver() }
                    if object is JumpBoard {
                        self.player.jump()
                        object.setDefault()
                    }
                }

                if object is Coin {
                    self.addScore()
                    object.setDefault()
                }

                if object is Boost {
                    self.increaseSpeed()
                    object.setDefault()
                }
            }
        }
    }
    
    private func setupFrameRateTimer() {
        self.frameRateTimer = Timer.scheduledTimer(withTimeInterval: .frameRate, repeats: true, block: { _ in
            self.checkPlayerIntersections()
        })
    }
    
    //MARK: setup timers funcs
    
    private func setupSpawnApexTimer() {
        self.spawnApexTimer = Timer.scheduledTimer(
            withTimeInterval: .apexSpawnRate * self.speedMultiplyer, repeats: true, block: { _ in
                guard let apex = self.apexes.filter({ $0.isPresented == false }).first else { return }
                apex.start(multiply: self.speedMultiplyer)
            })
    }
    
    private func setupSpawnBoostTimer() {
        self.spawnBoostTimer = Timer.scheduledTimer(withTimeInterval: .boostSpawnRate * self.speedMultiplyer, repeats: true, block: { _ in
            guard let boost = self.boosters.filter({ $0.isPresented == false }).first else { return }
            boost.start(multiply: self.speedMultiplyer)
        })
    }
    
    private func setupSpawnCoinsTimer() {
        self.spawnCoinsTimer = Timer.scheduledTimer(withTimeInterval: .coinsSpawnRate * self.speedMultiplyer, repeats: true, block: { _ in
            guard let coin = self.coins.filter({ $0.isPresented == false }).first else { return }
            coin.start(multiply: self.speedMultiplyer)
        })
    }
    
    private func setupSpawnJumpBoardTimer() {
        self.spawnJumpBoardTimer = Timer.scheduledTimer(withTimeInterval: .jumpBoardSpawnRate * self.speedMultiplyer, repeats: true, block: { _ in
            guard let jumpBoard = self.jumpBoards.filter({ $0.isPresented == false }).first else { return }
            jumpBoard.start(multiply: self.speedMultiplyer)
        })
    }
    
    //MARK: game flow funcs
    
    private func updateCurrentObjects() {
        for object in currentObjects {
            object.update(multiply: self.speedMultiplyer)
        }
    }
    
    private func addScore() {
        self.score += .scorePerCoin * self.scoreMultiplyer
        self.updateScore()
    }
    
    private func increaseSpeed() {
        self.speedMultiplyer *= .speedMultiplyer
        self.scoreMultiplyer += 1
        self.updateCurrentObjects()
        self.updateScore()
        self.refreshTimers()
    }
    
    private func refreshTimers() {
        self.switchTimers(false)
        self.switchTimers(true)
    }
    
    private func switchTimers(_ bool: Bool) {
        switch bool {
        case true:
            self.setupFrameRateTimer()
            self.setupSpawnApexTimer()
            self.setupSpawnJumpBoardTimer()
            self.setupSpawnCoinsTimer()
            self.setupSpawnBoostTimer()
        case false:
            self.frameRateTimer.invalidate()
            self.spawnApexTimer.invalidate()
            self.spawnCoinsTimer.invalidate()
            self.spawnJumpBoardTimer.invalidate()
            self.spawnBoostTimer.invalidate()
        }
    }
    
    private func startGame() {
        self.gameOverView.isHidden = true
        self.speedMultiplyer = .defaultSpeedMultiplyer
        self.scoreMultiplyer = .defaultScoreMultiplyer
        self.score = .startScore
        self.switchTimers(true)
        self.gameInProgress = true
        self.player.hideModel(false)
        self.updateScore()
        self.animateStatus(show: true)
    }
    
    private func gameOver() {
        StorageManager.shared.saveLastScore(self.score)
        self.gameOverView.isHidden = false
        self.gameInProgress = false
        self.switchTimers(false)
        self.player.hideModel(true)
        self.clearObjects()
        self.scoreLabel.setCyberverseFont(text: String("\(String.scoreText) \(score)"), size: .scoreFontSize)
        self.animateStatus(show: false)
    }
    
    private func setupObjects() {
        self.setupGameObjects()
        self.setupPlayerModel()
    }
    
    private func clearObjects() {
        for object in currentObjects {
            object.setDefault()
        }
        self.player.setStartPosition()
    }
    
    // MARK: UI funcs
    
    private func setupView() {
        self.retryButton.setCyberpnukFont(text: .retryButtonText, size: .buttonSize)
        self.mainMenuButton.setCyberpnukFont(text: .menuButtonText, size: .buttonSize)
        self.gameOverLabel.setCyberverseFont(text: .gameOverText, size: .gameOverFontSize)
        self.gameOverView.dropShadow()
        self.gameOverView.roundCorners()
        self.retryButton.dropShadow()
        self.retryButton.roundCorners()
        self.mainMenuButton.roundCorners()
        self.mainMenuButton.dropShadow()
    }
    
    private func updateScore() {
        self.inGameScoreLabel.setCyberverseFont(text: "\(String.scoreText) \(self.score)", size: .scoreFontSize)
        self.inGameMultiplyerLabel.setCyberverseFont(text: "x\(self.scoreMultiplyer)", size: .scoreFontSize)
    }
    
    private func animateStatus(show: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            switch show {
            case true:
                self.gameStatusBottomConstraint.constant = .constraintShowConstant
            case false:
                self.gameStatusBottomConstraint.constant = .constraintHideConstant
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: gesture recognizer
    
    private func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard gameInProgress else { return }
        
        let xPoint = recognizer.location(in: self.view).x
        
        if xPoint <= self.view.frame.width / 2 {
            player.detectPlayerMove(direction: .left)
        } else {
            player.detectPlayerMove(direction: .right)
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case retryButton:
            self.startGame()
        case mainMenuButton:
            self.navigationController?.popViewController(animated: false)
        default:
            break
        }
    }
}
