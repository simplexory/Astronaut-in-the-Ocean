import UIKit
import Foundation

final class GameViewController: UIViewController {
    
    // MARK: var / let
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    
    private let astronaut = Astronaut()
    private var apexes: [Apex] = []
    private var jumpBoards: [JumpBoard] = []
    private var coins: [Coin] = []
    private var frameRateTimer = Timer()
    private var spawnApexTimer = Timer()
    private var spawnJumpBoardTimer = Timer()
    private var spawnCoinsTimer = Timer()
    private var gameInProgress = false
    private var speedMultiplyer: Double = .defaultMultiplyer
    private var scoreMultiplyer: Int = .defaultScoreMultiplyer
    private var score: Int = .startScore
    
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
    
    // MARK: flow funcs
    
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
            
            apex.frame = CGRect(origin: origin, size: size)
            apex.setup()
            
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
            coin.setup()
            
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
            
            jumpBoard.frame = CGRect(origin: origin, size: size)
            jumpBoard.setup()
            
            jumpBoards.append(jumpBoard)
            self.view.addSubview(jumpBoard)
        }
    }
    
    private func checkObjectsIntersects() {
        if let astronautLayer = self.astronaut.layer.presentation() {
            
            for coin in self.coins {
                if let coinPresented = coin.layer.presentation() {
                    if coin.inMovement && coinPresented.frame.intersects(astronautLayer.frame) {
                        coin.take()
                        self.addScore(.scorePerCoin * scoreMultiplyer)
                    }
                }
            }
            
            guard !self.astronaut.isJumpingNow else { return }
            
            let astronautXPos = astronautLayer.frame.origin.x
            if astronautXPos <= 0 || astronautXPos >= self.view.frame.width - self.astronaut.frame.width {
                self.gameOver()
            }
            
            for apex in self.apexes {
                if let apexPresented = apex.layer.presentation() {
                    if apex.inMovement && apexPresented.frame.intersects(astronautLayer.frame) {
                        self.gameOver()
                    }
                }
            }
            
            for jumpBoard in self.jumpBoards {
                if let jumpBoardPresented = jumpBoard.layer.presentation() {
                    guard !jumpBoard.isUsed else { break }
                    
                    if jumpBoard.inMovement && jumpBoardPresented.frame.intersects(astronautLayer.frame) {
                        self.astronaut.jump(duration: .defaultJumpDuration * (self.speedMultiplyer / 2))
                    }
                }
            }
        }
    }
    
    private func setupFrameRateTimer() {
        self.frameRateTimer = Timer.scheduledTimer(withTimeInterval: .frameRate, repeats: true, block: { _ in
            self.checkObjectsIntersects()
        })
    }
    
    private func setupSpawnApexTimer(with multiplyer: Double) {
        self.spawnApexTimer = Timer.scheduledTimer(
            withTimeInterval: .apexSpawnRate * multiplyer, repeats: true, block: { _ in
            for apex in self.apexes {
                if !apex.inMovement {
                    apex.start(
                        timeInterval: .movementTime,
                        multiplyer: self.speedMultiplyer,
                        x: .random(in: 0...self.view.frame.width - apex.frame.width),
                        startY: -apex.frame.height,
                        endY: self.view.frame.height + apex.frame.height
                    )
                    return
                }
            }
        })
    }
    
    private func setupSpawnCoinsTimer(with multiplayer: Double) {
        self.spawnCoinsTimer = Timer.scheduledTimer(withTimeInterval: .coinsSpawnRate * multiplayer, repeats: true, block: { _ in
            for coin in self.coins {
                if !coin.inMovement {
                    coin.start(
                        timeInterval: .movementTime,
                        multiplyer: self.speedMultiplyer,
                        x: .random(in: 0...self.view.frame.width - coin.frame.width),
                        startY: -coin.frame.width,
                        endY: self.view.frame.height + coin.frame.height
                    )
                    return
                }
            }
        })
    }
    
    private func setupSpawnJumpBoardTimer(with multiplyer: Double) {
        self.spawnJumpBoardTimer = Timer.scheduledTimer(withTimeInterval: .jumpBoardSpawnRate * multiplyer, repeats: true, block: { _ in
            for jumpBoard in self.jumpBoards {
                if !jumpBoard.inMovement {
                    jumpBoard.start(
                        timeInterval: .movementTime,
                        multiplyer: self.speedMultiplyer,
                        x: .random(in: 0...self.view.frame.width - jumpBoard.frame.width),
                        startY: -jumpBoard.frame.height,
                        endY: self.view.frame.height + jumpBoard.frame.height
                    )
                    return
                }
            }
        })
    }
    
    private func addScore(_ number: Int) {
        self.score += number * self.scoreMultiplyer
    }
    
    private func increaseSpeed() {
        self.speedMultiplyer *= 0.9
        self.refreshTimers()
    }
    
    private func refreshTimers() {
        self.switchTimers(action: .disable)
        self.switchTimers(action: .enable)
    }
    
    private func switchTimers(action: Status) {
        switch action {
        case .enable:
            self.setupFrameRateTimer()
            self.setupSpawnApexTimer(with: self.speedMultiplyer)
            self.setupSpawnJumpBoardTimer(with: self.speedMultiplyer)
            self.setupSpawnCoinsTimer(with: self.speedMultiplyer)
        case .disable:
            self.frameRateTimer.invalidate()
            self.spawnApexTimer.invalidate()
            self.spawnCoinsTimer.invalidate()
            self.spawnJumpBoardTimer.invalidate()
        }
    }
    
    private func setupGameObjects() {
        self.setupPlayerModel()
        self.setupApexesModel()
        self.setupJumpBoardsModel()
        self.setupCoinsModel()
    }
    
    private func startGame() {
        self.speedMultiplyer = .defaultMultiplyer
        self.score = .startScore
        self.switchTimers(action: .enable)
        self.gameInProgress = true
        self.astronaut.startAnimating()
        self.astronaut.isHidden = false
        self.gameOverView.isHidden = true
    }
    
    private func gameOver() {
        self.gameInProgress = false
        self.switchTimers(action: .disable)
        self.astronaut.isHidden = true
        self.astronaut.stopAnimating()
        self.gameOverView.isHidden = false
        self.clearObjects()
        self.setupGameObjects()
        self.scoreLabel.text = "Score: \(score)"
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
        
        self.jumpBoards.removeAll()
        self.apexes.removeAll()
        self.coins.removeAll()
    }
    
    private func setupGameOverView() {
        self.gameOverView.dropShadow()
        self.gameOverView.roundCorners()
        self.retryButton.dropShadow()
        self.retryButton.roundCorners()
        self.mainMenuButton.roundCorners()
        self.mainMenuButton.dropShadow()
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
