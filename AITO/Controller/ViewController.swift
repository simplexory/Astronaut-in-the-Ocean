//
//  ViewController.swift
//  AITO
//
//  Created by Юра Ганкович on 3.11.22.
//

import UIKit
import Foundation

private extension CGFloat {
    static let contentDivider: CGFloat = 6
    static let paddingBottomMultiplyer: CGFloat = 2.5
}

final class ViewController: UIViewController {
    
    private let astronaut = Astronaut()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPanGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareAstronautForFly()
    }
    
    private func prepareAstronautForFly() {
        let computedWidth = self.view.frame.width / .contentDivider
        let startPoint = CGPoint(
            x: self.view.frame.width / 2 - computedWidth / 2,
            y: self.view.frame.height - computedWidth * .paddingBottomMultiplyer)
        let size = CGSize(width: computedWidth, height: computedWidth)
        
        self.astronaut.frame = CGRect(origin: startPoint, size: size)
        self.astronaut.addSelfAnimation()
        self.view.addSubview(self.astronaut)
    }
    
    private func addPanGestureRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureDetected(_:)))
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc
    private func panGestureDetected(_ recognizer: UIPanGestureRecognizer) {
        let xPoint = recognizer.location(in: self.view).x
        if xPoint <= self.view.frame.width / 2 {
            detectPlayerMove(direction: .left)
        } else {
            detectPlayerMove(direction: .right)
        }
    }
    
    private func detectPlayerMove(direction: Move) {
        switch direction {
        case .left:
            print("left")
        case .right:
            print("right")
        }
    }

}
