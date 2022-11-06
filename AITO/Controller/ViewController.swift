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
    static let maximumContentDivider: CGFloat = 10
    static let paddingBottomMultiplyer: CGFloat = 2.5
}

private extension Int {
    static let maxApexCount = 10
}

private extension TimeInterval {
    static let frameRate: TimeInterval = 1 / 60
    static let apexSpawnRate: TimeInterval = 2
    static let apexMovementTime: TimeInterval = 6
}

final class ViewController: UIViewController {
    
    // MARK: var / let
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    
    private let astronaut = Astronaut()
    private var apexes: [Apex] = []
    private var frameRateTimer = Timer()
    private var spawnApexTimer = Timer()
    private var gameInProgress = false
    private var speedMultiplyer: Double = 1
    private var retryGameView = UIView()
    private var score = 0
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startGame()
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
    
    // MARK: flow funcs
    
    private func configurePlayerModel() {
        let computedWidth = self.view.frame.width / .contentDivider
        let startPoint = CGPoint(
            x: self.view.frame.width / 2 - computedWidth / 2,
            y: self.view.frame.height - computedWidth * .paddingBottomMultiplyer)
        let size = CGSize(width: computedWidth, height: computedWidth)
        
        self.astronaut.frame = CGRect(origin: startPoint, size: size)
        self.astronaut.configurePlayerAnimation()
        self.view.addSubview(self.astronaut)
    }
    
    private func configureApexesModel() {
        for _ in 0...Int.maxApexCount {
            let apex = Apex()
            let computedWidth = self.view.frame.width / .random(in: CGFloat.contentDivider...CGFloat.maximumContentDivider)
            let size = CGSize(width: computedWidth, height: computedWidth)
            let origin = CGPoint(x: 0, y: -computedWidth)
            
            apex.frame = CGRect(origin: origin, size: size)
            apex.configureApex()
            
            apexes.append(apex)
            self.view.addSubview(apex)
        }
    }
    
    private func configureFrameRateTimer() {
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
            }
        })
    }
    
    private func configureSpawnApexTimer(with multiplyer: Double) {
        self.spawnApexTimer = Timer.scheduledTimer(
            withTimeInterval: .apexSpawnRate * multiplyer, repeats: true, block: { _ in
            for apex in self.apexes {
                if !apex.inMovement {
                    apex.startApexMovement(
                        timeInterval: .apexMovementTime,
                        multiplyer: self.speedMultiplyer,
                        x: .random(in: 0...self.view.frame.width - apex.frame.width),
                        startY: -apex.frame.height,
                        endY: self.view.frame.height + apex.frame.height)
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
        self.configureSpawnApexTimer(with: self.speedMultiplyer)
        self.spawnApexTimer.fire()
    }
    
    private func setupGameUI() {
        self.addTapGestureRecognizer()
        self.configureFrameRateTimer()
        self.configureSpawnApexTimer(with: speedMultiplyer)
        self.configurePlayerModel()
        self.configureApexesModel()
    }
    
    private func startGame() {
        self.gameInProgress = true
        self.speedMultiplyer = 1
        self.frameRateTimer.fire()
        self.spawnApexTimer.fire()
        self.astronaut.startAnimating()
    }
    
    private func gameOver() {
        self.gameInProgress = false
        self.frameRateTimer.invalidate()
        self.spawnApexTimer.invalidate()
        self.astronaut.isHidden = true
        self.astronaut.stopAnimating()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case retryButton:
            break
        case mainMenuButton:
            break
        default:
            break
        }
    }
}
