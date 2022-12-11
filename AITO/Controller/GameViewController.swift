import UIKit

private extension CGFloat {
    static let constraintShowConstant: CGFloat = 20
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

private extension TimeInterval {
    static let statusAnimatingDuration: TimeInterval = 0.5
}

class GameViewController: UIViewController {
    
    // MARK: var / let
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var inGameScoreLabel: UILabel!
    @IBOutlet weak var inGameMultiplyerLabel: UILabel!
    @IBOutlet weak var gameStatusBottomConstraint: NSLayoutConstraint!
    
    var difficult: Difficult = .normal
    private let player = Player()
    private let background = Background()
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
    private var gameIsStarted = false
    private var score: Int = .startScore
    private var startMatch: Date?
    
    private var currentObjects: [GameObject] {
        get {
            var objects: [GameObject] = []
            objects.append(contentsOf: apexes.filter({ $0.isPresented }))
            objects.append(contentsOf: coins.filter({ $0.isPresented }))
            objects.append(contentsOf: jumpBoards.filter({ $0.isPresented }))
            objects.append(contentsOf: boosters.filter({ $0.isPresented }))
            return objects
        }
    }
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupGameObjects()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGame()
        background.setDefault()
        background.start(multiplyer: speedMultiplyer)
    }
    
    // MARK: setup model func
    
    private func setupGameObjects() {
        let maxY = self.view.frame.height
        let maxX = self.view.frame.width
        // setup player
        player.setup(viewWidth: self.gameView.frame.width, viewHeight: self.gameView.frame.height)
        // setup background
        background.setup(screenWidth: self.gameView.frame.width, screenHeight: self.gameView.frame.height)
        gameView.addSubview(background.bottomImageView)
        gameView.addSubview(background.topImageView)
        gameView.addSubview(player.waterCollision)
        // setup apexes
        for _ in 0..<Int.apexObjectsCount {
            let randomDivider: CGFloat = .random(in: CGFloat.minApexContentDivider...CGFloat.maxApexContentDivider)
            let apexSize: CGFloat = gameView.frame.width / randomDivider
            let apex = Apex(size: apexSize, maxY: maxY, maxX: maxX, divider: randomDivider)
            
            apexes.append(apex)
            gameView.addSubview(apex.model)
        }
        //setup coins
        let coinSize: CGFloat = gameView.frame.width / .coinContentDivider
        for _ in 0..<Int.coinObjectCount {
            let coin = Coin(size: coinSize, maxY: maxY, maxX: maxX, divider: .coinContentDivider)
            
            coins.append(coin)
            gameView.addSubview(coin.model)
        }
        // setup boosters
        let boosterSize = gameView.frame.width / CGFloat.boosterContentDivider
        for _ in 0..<Int.apexObjectsCount {
            let boost = Boost(size: boosterSize, maxY: maxY, maxX: maxX, divider: .boosterContentDivider)

            boosters.append(boost)
            gameView.addSubview(boost.model)
        }
        // setup jump boards
        for _ in 0..<Int.jumpBoardObjectsCount {
            let jumpBoard = JumpBoard(size: coinSize, maxY: maxY, maxX: maxX, divider: .coinContentDivider)
            
            jumpBoards.append(jumpBoard)
            gameView.addSubview(jumpBoard.model)
        }
        gameView.addSubview(player.model)
    }
    
    //MARK: intersections block
    
    private func checkPlayerIntersections() {
        if !player.inCorrectPosition() && !player.isJumpingNow { gameOver() }
        guard let playerLayer = player.model.layer.presentation() else { return }
        let intersection = checkIntersections(for: playerLayer.frame)
        
        if intersection.status {
            guard let object = intersection.object else { return }
            
            if player.isJumpingNow == false {
                if object is Apex { gameOver() }
                if object is JumpBoard { player.jump(); object.setDefault() }
            }

            if object is Coin { addScore(); object.setDefault() }
            if object is Boost { increaseSpeed(); object.setDefault() }
        }
    }
    
    private func checkIntersections(for frame: CGRect) -> (status: Bool, object: GameObject?) {
        for object in currentObjects {
            guard let objectFrame = object.frame else { return (false, nil) }
            if objectFrame.intersects(frame) { return (true, object) }
        }
        
        return (false, nil)
    }
    
    //MARK: setup timers funcs
    
    private func setupFrameRateTimer() {
        frameRateTimer = Timer.scheduledTimer(withTimeInterval: .frameRate, repeats: true, block: { _ in
            self.checkPlayerIntersections()
        })
    }
    
    private func setupSpawnApexTimer() {
        spawnApexTimer = Timer.scheduledTimer(
            withTimeInterval: .apexSpawnRate * speedMultiplyer, repeats: true, block: { _ in
                guard let apex = self.apexes.filter({ $0.isPresented == false }).first else { return }
                apex.start(multiply: self.speedMultiplyer, x: self.getRandomXPosition(for: apex))
            })
    }
    
    private func setupSpawnBoostTimer() {
        spawnBoostTimer = Timer.scheduledTimer(withTimeInterval: .boostSpawnRate * speedMultiplyer, repeats: true, block: { _ in
            guard let boost = self.boosters.filter({ $0.isPresented == false }).first else { return }
            boost.start(multiply: self.speedMultiplyer, x: self.getRandomXPosition(for: boost))
        })
    }
    
    private func setupSpawnCoinsTimer() {
        spawnCoinsTimer = Timer.scheduledTimer(withTimeInterval: .coinsSpawnRate * speedMultiplyer, repeats: true, block: { _ in
            guard let coin = self.coins.filter({ $0.isPresented == false }).first else { return }
            coin.start(multiply: self.speedMultiplyer, x: self.getRandomXPosition(for: coin))
        })
    }
    
    private func setupSpawnJumpBoardTimer() {
        spawnJumpBoardTimer = Timer.scheduledTimer(withTimeInterval: .jumpBoardSpawnRate * speedMultiplyer, repeats: true, block: { _ in
            guard let jumpBoard = self.jumpBoards.filter({ $0.isPresented == false }).first else { return }
            jumpBoard.start(multiply: self.speedMultiplyer, x: self.getRandomXPosition(for: jumpBoard))
        })
    }
    
    //MARK: game flow funcs
    
    private func getRandomXPosition(for object: GameObject) -> CGFloat {
        var x = CGFloat()
        
        repeat {
            x = object.getRandomPosition()
            object.model.frame.origin.x = x
        } while checkIntersections(for: object.model.frame).status
        
        return x
    }
    
    private func updateCurrentObjects() {
        for object in currentObjects {
            object.update(multiply: speedMultiplyer)
        }
    }
    
    private func addScore() {
        score += .scorePerCoin * scoreMultiplyer
        updateScore()
    }
    
    private func increaseSpeed() {
        speedMultiplyer *= .speedMultiplyer
        scoreMultiplyer += 1
        updateCurrentObjects()
        updateScore()
        refreshTimers()
        background.update(multiplyer: speedMultiplyer)
    }
    
    private func refreshTimers() {
        switchTimers(false)
        switchTimers(true)
    }
    
    private func switchTimers(_ bool: Bool) {
        switch bool {
        case true:
            setupFrameRateTimer()
            RunLoop.main.add(frameRateTimer, forMode: .common)
            setupSpawnApexTimer()
            RunLoop.main.add(spawnApexTimer, forMode: .common)
            setupSpawnJumpBoardTimer()
            RunLoop.main.add(spawnJumpBoardTimer, forMode: .common)
            setupSpawnCoinsTimer()
            RunLoop.main.add(spawnCoinsTimer, forMode: .common)
            setupSpawnBoostTimer()
            RunLoop.main.add(spawnBoostTimer, forMode: .common)
        case false:
            frameRateTimer.invalidate()
            spawnApexTimer.invalidate()
            spawnCoinsTimer.invalidate()
            spawnJumpBoardTimer.invalidate()
            spawnBoostTimer.invalidate()
        }
    }
    
    private func startGame() {
        gameOverView.isHidden = true
        speedMultiplyer = .defaultSpeedMultiplyer
        scoreMultiplyer = .defaultScoreMultiplyer
        score = .startScore
        switchTimers(true)
        gameIsStarted = true
        player.hideModel(false)
        updateScore()
        animateStatus(show: true)
        background.update(multiplyer: speedMultiplyer)
        player.animateWaterCollision()
        startMatch = Date()
    }
    
    private func gameOver() {
        let match = saveMatch()
        background.stop()
        gameOverView.isHidden = false
        gameIsStarted = false
        switchTimers(false)
        player.hideModel(true)
        clearObjects()
        scoreLabel.setCyberverseFont(text: String("\(String.scoreText) \(match!.score) : \(match!.time.asMatchTime())"), size: .scoreFontSize)
        animateStatus(show: false)
    }
    
    private func saveMatch() -> PlayerMatch? {
        guard let startMatch = startMatch else { return nil }
        let matchTime = startMatch - Date()
        let username = StorageManager.shared.loadName()
        let match = PlayerMatch(name: username, score: self.score, time: matchTime, difficult: self.difficult)
        
        StorageManager.shared.saveMatch(match: match)
        
        return match
    }
    
    private func clearObjects() {
        for object in currentObjects {
            object.setDefault()
        }
        player.setStartPosition()
    }
    
    // MARK: UI funcs
    
    private func setupView() {
        retryButton.setCyberpnukFont(text: .retryButtonText, size: .buttonSize)
        mainMenuButton.setCyberpnukFont(text: .menuButtonText, size: .buttonSize)
        gameOverLabel.setCyberverseFont(text: .gameOverText, size: .gameOverFontSize)
        gameOverView.dropShadow()
        gameOverView.roundCorners()
        retryButton.dropShadow()
        retryButton.roundCorners()
        mainMenuButton.roundCorners()
        mainMenuButton.dropShadow()
    }
    
    private func updateScore() {
        inGameScoreLabel.setCyberverseFont(text: "\(String.scoreText) \(score)", size: .scoreFontSize)
        inGameMultiplyerLabel.setCyberverseFont(text: "x\(scoreMultiplyer)", size: .scoreFontSize)
    }
    
    private func animateStatus(show: Bool) {
        UIView.animate(withDuration: .statusAnimatingDuration, delay: 0, options: .curveEaseInOut) {
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
        view.addGestureRecognizer(recognizer)
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard gameIsStarted else { return }
        
        let xPoint = recognizer.location(in: view).x
        
        if xPoint <= view.frame.width / 2 {
            player.detectPlayerMove(direction: .left)
        } else {
            player.detectPlayerMove(direction: .right)
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case retryButton:
            startGame()
        case mainMenuButton:
            navigationController?.popViewController(animated: false)
        default:
            break
        }
    }
}
