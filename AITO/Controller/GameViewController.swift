//
//  ViewController.swift
//  AITO
//
//  Created by Юра Ганкович on 3.11.22.
//

import UIKit
import Foundation

// MARK: private extensions

private extension CGFloat {
    static let contentDivider: CGFloat = 6
    static let maxContentDivider: CGFloat = 10
    static let paddingBottomAstronautMultiplyer: CGFloat = 2.2
}

private extension Double {
    static let defaultMultiplyer = 1.0
}

private extension Int {
    static let apexObjectsCount = 12
    static let jumpBoardObjectsCount = 3
    static let startScore = 0
}

private extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 60
    static let apexSpawnRate: TimeInterval = 2.1
    static let jumpBoardSpawnRate: TimeInterval = 6
    static let movementTime: TimeInterval = 6
    static let defaultJumpDuration: TimeInterval = 2.3
}

final class GameViewController: UIViewController {
    
    // MARK: var / let
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    
    private let astronaut = Astronaut()
    private var apexes: [Apex] = []
    private var jumpBoards: [JumpBoard] = []
    private var frameRateTimer = Timer()
    private var spawnApexTimer = Timer()
    private var spawnJumpBoardTimer = Timer()
    private var gameInProgress = false
    private var speedMultiplyer: Double = .defaultMultiplyer
    private var scoreMultiplyer: Double = .defaultMultiplyer
    private var score: Int = .startScore
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGestureRecognizer()
        self.setupGameUI()
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
        self.astronaut.setupPlayerAnimation()
        self.view.addSubview(self.astronaut)
    }
    
    private func setupApexesModel() {
        for _ in 0..<Int.apexObjectsCount {
            let apex = Apex()
            let computedWidth = self.view.frame.width / .random(in: CGFloat.contentDivider...CGFloat.maxContentDivider)
            let size = CGSize(width: computedWidth, height: computedWidth)
            let origin = CGPoint(x: 0, y: -computedWidth)
            
            apex.frame = CGRect(origin: origin, size: size)
            apex.setupApex()
            
            apexes.append(apex)
            self.view.addSubview(apex)
        }
    }
    
    private func setupJumpBoardModel() {
        let computeWidth = self.view.frame.width / .maxContentDivider
        let size = CGSize(width: computeWidth, height: computeWidth)
        let origin = CGPoint(x: 0, y: -computeWidth)
        
        for _ in 0..<Int.jumpBoardObjectsCount {
            let jumpBoard = JumpBoard()
            
            jumpBoard.frame = CGRect(origin: origin, size: size)
            jumpBoard.setupJumpBoard()
            
            jumpBoards.append(jumpBoard)
            self.view.addSubview(jumpBoard)
        }
    }
    
    private func setupFrameRateTimer() {
        self.frameRateTimer = Timer.scheduledTimer(withTimeInterval: .frameRate, repeats: true, block: { _ in
            guard !self.astronaut.isJumpingNow else { return }
            
            if let astronautLayer = self.astronaut.layer.presentation() {
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
                        
                        if jumpBoard.inMovement && jumpBoardPresented.frame.intersects(astronautLayer.frame)  {
                            self.astronaut.jump(duration: .defaultJumpDuration * (self.speedMultiplyer / 2))
                        }
                    }
                }
            }
        })
    }
    
    private func setupSpawnApexTimer(with multiplyer: Double) {
        self.spawnApexTimer = Timer.scheduledTimer(
            withTimeInterval: .apexSpawnRate * multiplyer, repeats: true, block: { _ in
            for apex in self.apexes {
                if !apex.inMovement {
                    apex.startApexMovement(
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
    
    private func setupSpawnJumpBoardTimer(with multiplyer: Double) {
        self.spawnJumpBoardTimer = Timer.scheduledTimer(withTimeInterval: .jumpBoardSpawnRate * multiplyer, repeats: true, block: { _ in
            for jumpBoard in self.jumpBoards {
                if !jumpBoard.inMovement {
                    jumpBoard.startJumpBoardMovement(
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
    
    private func increaseSpeed() {
        self.speedMultiplyer *= 0.9
        self.refreshTimers()
    }
    
    private func refreshTimers() {
        self.spawnApexTimer.invalidate()
        self.spawnJumpBoardTimer.invalidate()
        self.setupSpawnApexTimer(with: self.speedMultiplyer)
        self.setupSpawnJumpBoardTimer(with: self.speedMultiplyer)
    }
    
    private func setupGameUI() {
        self.setupPlayerModel()
        self.setupApexesModel()
        self.setupJumpBoardModel()
    }
    
    private func startGame() {
        self.speedMultiplyer = 1
        self.score = 0
        self.setupFrameRateTimer()
        self.setupSpawnApexTimer(with: self.speedMultiplyer)
        self.setupSpawnJumpBoardTimer(with: self.speedMultiplyer)
        self.gameInProgress = true
        self.frameRateTimer.fire()
        self.spawnApexTimer.fire()
        self.astronaut.startAnimating()
        self.astronaut.isHidden = false
        self.gameOverView.isHidden = true
    }
    
    private func gameOver() {
        self.gameInProgress = false
        self.frameRateTimer.invalidate()
        self.spawnApexTimer.invalidate()
        self.spawnJumpBoardTimer.invalidate()
        self.astronaut.isHidden = true
        self.astronaut.stopAnimating()
        self.gameOverView.isHidden = false
        
        for jumpBoard in jumpBoards {
            jumpBoard.removeFromSuperview()
        }
        
        for apex in apexes {
            apex.removeFromSuperview()
        }
        
        self.jumpBoards = []
        self.apexes = []
        
        self.setupGameUI()
        self.scoreLabel.text = "Score: \(score)"
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
