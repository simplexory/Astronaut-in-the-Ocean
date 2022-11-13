import UIKit
import Foundation

private extension CGFloat {
    static let constraintShowConstant: CGFloat = 15
    static let constraintHideConstraint: CGFloat = -100
}

final class GameViewController: UIViewController {
    
    // MARK: var / let
    
    /**
                ADD SPEED BOUNTY
                ADD FONTS
                ADD BACKGROUND
                ADD SMTH BETTER THEN THIS SHITTY MODELS
     */
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var inGameScoreLabel: UILabel!
    @IBOutlet weak var inGameMultiplyerLabel: UILabel!
    @IBOutlet weak var gameStatusBottomConstraint: NSLayoutConstraint!
    
    var score: Int = .startScore
    private let astronaut = Astronaut()
    private var apexes: [Apex] = []
    private var jumpBoards: [JumpBoard] = []
    private var coins: [Coin] = []
    private var frameRateTimer = Timer()
    private var spawnApexTimer = Timer()
    private var spawnJumpBoardTimer = Timer()
    private var spawnCoinsTimer = Timer()
    private var gameInProgress = false
    private var speedMultiplyer: Double = .defaultSpeedMultiplyer
    private var scoreMultiplyer: Int = .defaultScoreMultiplyer
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGestureRecognizer()
        self.setupGameObjects()
        self.setupGameOverView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.startGame()
    }
    
    // MARK: setup model funcs
    
    private func setupPlayerModel() {
        let computedWidth = self.view.frame.width / .contentDivider
        let startPoint = CGPoint(
            x: self.view.frame.width / 2 - computedWidth / 2,
            y: self.view.frame.height - computedWidth * .paddingBottomAstronautMultiplyer)
        let size = CGSize(width: computedWidth, height: computedWidth)
        
        self.astronaut.frame = CGRect(origin: startPoint, size: size)
        self.astronaut.setup()
        self.view.addSubview(self.astronaut)
    }
    
    private func setupApexesModel() {
        for _ in 0..<Int.apexObjectsCount {
            let apex = Apex()
            let computedWidth = self.view.frame.width / .random(in: CGFloat.contentDivider...CGFloat.maxContentDivider)
            let size = CGSize(width: computedWidth, height: computedWidth)
            let origin = CGPoint(x: 0, y: -computedWidth)
            
            apex.setup(origin: origin, size: size, endY: self.view.frame.height + computedWidth)
            
            apexes.append(apex)
            self.view.addSubview(apex)
        }
    }
    
    private func setupCoinsModel() {
        let computedWidth = self.view.frame.width / CGFloat.maxContentDivider
        let size = CGSize(width: computedWidth, height: computedWidth)
        let origin = CGPoint(x: 0, y: -computedWidth)
        
        for _ in 0..<Int.coinObjectCount {
            let coin = Coin()
            
            coin.frame = CGRect(origin: origin, size: size)
            coin.setup(origin: origin, size: size, endY: self.view.frame.height + computedWidth)
            
            coins.append(coin)
            self.view.addSubview(coin)
        }
    }
    
    private func setupJumpBoardsModel() {
        let computeWidth = self.view.frame.width / .maxContentDivider
        let size = CGSize(width: computeWidth, height: computeWidth)
        let origin = CGPoint(x: 0, y: -computeWidth)
        
        for _ in 0..<Int.jumpBoardObjectsCount {
            let jumpBoard = JumpBoard()
            
            jumpBoard.setup(origin: origin, size: size, endY: self.view.frame.height + computeWidth)
            
            self.jumpBoards.append(jumpBoard)
            self.view.addSubview(jumpBoard)
        }
    }
    
    //MARK: intersects funcs
    
    func checkCoinIntersect(layer: CALayer) {
        for coin in self.coins.filter({ $0.isUsed == false && $0.inMovement }) {
            if let coinPresented = coin.layer.presentation() {
                if coinPresented.frame.intersects(layer.frame) {
                    coin.take()
                    self.addScore(.scorePerCoin)
                }
            }
        }
    }
    
    func checkApexIntersect(layer: CALayer) {
        for apex in self.apexes.filter({ $0.inMovement }) {
            if let apexPresented = apex.layer.presentation() {
                if apexPresented.frame.intersects(layer.frame) {
                    self.gameOver()
                }
            }
        }
    }
    
    func checkJumpBoardIntersect(layer: CALayer) {
        for jumpBoard in self.jumpBoards.filter({ $0.isUsed == false && $0.inMovement }) {
            if let jumpBoardPresented = jumpBoard.layer.presentation() {
                if jumpBoardPresented.frame.intersects(layer.frame) {
                    self.astronaut.jump(duration: .defaultJumpDuration)
                }
            }
        }
    }
    
    private func checkObjectsIntersects() {
        if let astronautLayer = self.astronaut.layer.presentation() {
            self.checkCoinIntersect(layer: astronautLayer)
            
            if self.astronaut.isJumpingNow { return }
            
            guard astronaut.inCorrectPosition() else { return gameOver() }
            
            self.checkApexIntersect(layer: astronautLayer)
            self.checkJumpBoardIntersect(layer: astronautLayer)
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
                guard let apex = self.apexes.filter({ $0.inMovement == false }).first else { return }
                let randomX: CGFloat = .random(in: 0...self.view.frame.width - apex.frame.width)
                apex.start(x: randomX)
        })
    }
    
    private func setupSpawnCoinsTimer() {
        self.spawnCoinsTimer = Timer.scheduledTimer(withTimeInterval: .coinsSpawnRate * self.speedMultiplyer, repeats: true, block: { _ in
            guard let coin = self.coins.filter({ $0.inMovement == false }).first else { return }
            coin.start(x: .random(in: 0...self.view.frame.width - coin.frame.width))
        })
    }
    
    private func setupSpawnJumpBoardTimer() {
        self.spawnJumpBoardTimer = Timer.scheduledTimer(withTimeInterval: .jumpBoardSpawnRate * self.speedMultiplyer, repeats: true, block: { _ in
            guard let jumpBoard = self.jumpBoards.filter({ $0.inMovement == false }).first else { return }
            let randomX: CGFloat = .random(in: 0...self.view.frame.width - jumpBoard.frame.width)
            jumpBoard.start(x: randomX)
        })
    }
    
    //MARK: game flow funcs
    
    private func addScore(_ number: Int) {
        self.score += number * self.scoreMultiplyer
        self.updateScore()
    }
    
    private func increaseSpeed() {
        self.speedMultiplyer *= .speedMultiplyer
        self.refreshTimers()
    }
    
    private func refreshTimers() {
        self.switchTimers(true)
        self.switchTimers(false)
    }
    
    private func switchTimers(_ bool: Bool) {
        switch bool {
        case true:
            self.setupFrameRateTimer()
            self.setupSpawnApexTimer()
            self.setupSpawnJumpBoardTimer()
            self.setupSpawnCoinsTimer()
        case false:
            self.frameRateTimer.invalidate()
            self.spawnApexTimer.invalidate()
            self.spawnCoinsTimer.invalidate()
            self.spawnJumpBoardTimer.invalidate()
        }
    }
    
    private func setupGameObjects() {
        self.setupApexesModel()
        self.setupJumpBoardsModel()
        self.setupCoinsModel()
        self.setupPlayerModel()
    }
    
    private func startGame() {
        self.gameOverView.isHidden = true
        self.speedMultiplyer = .defaultSpeedMultiplyer
        self.score = .startScore
        self.switchTimers(true)
        self.gameInProgress = true
        self.astronaut.hideModel(false)
        self.updateScore()
        self.animateStatus(show: true)
    }
    
    private func gameOver() {
        self.gameOverView.isHidden = false
        self.gameInProgress = false
        self.switchTimers(false)
        self.astronaut.hideModel(true)
        self.clearObjects()
        self.setupGameObjects()
        self.scoreLabel.text = "Score: \(score)"
        self.animateStatus(show: false)
    }
    
    private func clearObjects() {
        for jumpBoard in self.jumpBoards {
            jumpBoard.removeFromSuperview()
        }
        
        for apex in self.apexes {
            apex.removeFromSuperview()
        }
        
        for coin in self.coins {
            coin.removeFromSuperview()
        }
        
        self.astronaut.removeFromSuperview()
        self.jumpBoards.removeAll()
        self.apexes.removeAll()
        self.coins.removeAll()
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
                self.gameStatusBottomConstraint.constant = .constraintHideConstraint
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
            astronaut.detectPlayerMove(direction: .left)
        } else {
            astronaut.detectPlayerMove(direction: .right)
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
