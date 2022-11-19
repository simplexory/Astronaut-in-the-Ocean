import UIKit

private extension CGFloat {
    static let constraintShowConstant: CGFloat = 15
    static let constraintHideConstant: CGFloat = -100
}

final class GameViewController: UIViewController {
    
    // MARK: var / let
    
    /** TODO:
            ADD FONTS
            ADD BACKGROUND !
            ADD BETTER ASTRONAUT DESIGN
     */
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
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
        self.setupAll()
        self.setupGameOverView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startGame()
    }
    
    // MARK: setup model funcs
    
    private func setupPlayerModel() {
        let size = self.view.frame.width / .contentDivider
        let startPoint = CGPoint(
            x: self.view.frame.width / 2 - size / 2,
            y: self.view.frame.height - size * .paddingBottomPlayerMultiplyer)
        
        self.player.setup(startPos: startPoint, size: size)
        self.view.addSubview(self.player)
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
    
    //MARK: intersects funcs
    
    private func checkCoinIntersect(layer: CALayer) {
        for coin in self.coins.filter({ $0.isPresented }) {
            if let frame = coin.frame {
                if frame.intersects(layer.frame) {
                    coin.setDefault()
                    self.addScore(.scorePerCoin)
                }
            }
        }
    }
    
    private func checkBoostIntersect(layer: CALayer) {
        for boost in self.boosters.filter({ $0.isPresented }) {
            if let frame = boost.frame {
                if frame.intersects(layer.frame) {
                    boost.setDefault()
                    self.increaseSpeed()
                }
            }
        }
    }
    
    private func checkApexIntersect(layer: CALayer) {
        for apex in self.apexes.filter({ $0.isPresented }) {
            if let frame = apex.frame {
                if frame.intersects(layer.frame) {
                    self.gameOver()
                }
            }
        }
    }
    
    private func checkJumpBoardIntersect(layer: CALayer) {
        for jumpBoard in self.jumpBoards.filter({ $0.isPresented }) {
            if let frame = jumpBoard.frame {
                if frame.intersects(layer.frame) {
                    self.player.jump(duration: .defaultJumpDuration)
                    jumpBoard.setDefault()
                }
            }
        }
    }
    #warning("REMOVE THIS")
//    private func badCheckIntersectIdea() {
//        guard let playerLayer = self.player.layer.presentation() else { return }
//
//        if !player.inCorrectPosition() && !self.player.isJumpingNow { self.gameOver() }
//
//        for object in currentObjects {
//            guard let frame = object.frame else { break }
//
//            if frame.intersects(playerLayer.frame) {
//                if self.player.isJumpingNow == false {
//
//                    if let _ = object as? Apex {
//                        self.gameOver()
//                    }
//
//                    if let _ = object as? JumpBoard {
//                        self.player.jump(duration: .defaultJumpDuration)
//                        object.setDefault()
//                    }
//                }
//
//                if let _ = object as? Coin {
//                    self.addScore(.scorePerCoin)
//                    object.setDefault()
//                }
//
//                if let _ = object as? Boost {
//                    self.increaseSpeed()
//                    object.setDefault()
//                }
//            }
//        }
//    }
    
    private func checkObjectsIntersects() {
        if let playerLayer = self.player.layer.presentation() {
            self.checkCoinIntersect(layer: playerLayer)
            self.checkBoostIntersect(layer: playerLayer)

            if self.player.isJumpingNow { return }
            guard player.inCorrectPosition() else { return self.gameOver() }

            self.checkApexIntersect(layer: playerLayer)
            self.checkJumpBoardIntersect(layer: playerLayer)
        }
    }
    
    private func setupFrameRateTimer() {
        self.frameRateTimer = Timer.scheduledTimer(withTimeInterval: .frameRate, repeats: true, block: { _ in
            self.checkObjectsIntersects()
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
    
    private func addScore(_ number: Int) {
        self.score += number * self.scoreMultiplyer
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
        self.gameOverView.isHidden = false
        self.gameInProgress = false
        self.switchTimers(false)
        self.player.hideModel(true)
        self.clearObjects()
        self.scoreLabel.text = "Score: \(score)"
        self.animateStatus(show: false)
    }
    
    private func setupAll() {
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
    
    private func setupGameOverView() {
        self.gameOverView.dropShadow()
        self.gameOverView.roundCorners()
        self.retryButton.dropShadow()
        self.retryButton.roundCorners()
        self.mainMenuButton.roundCorners()
        self.mainMenuButton.dropShadow()
    }
    
    private func updateScore() {
        self.inGameScoreLabel.text = "SCORE: \(self.score)"
        self.inGameMultiplyerLabel.text = "x\(self.scoreMultiplyer)"
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
