//
//  JumpBoardModel.swift
//  AITO
//
//  Created by Юра Ганкович on 6.11.22.
//

import UIKit

private extension String {
    static let modelName = "jumpboard"
    static let fileFormat = ".png"
}

final class JumpBoard: UIImageView {
   
    var inMovement = false
    var isUsed = false
    
    func setupJumpBoard() {
        self.layer.contentsGravity = .resize
        self.layer.borderWidth = 2
        self.image = UIImage(named: .modelName + .fileFormat)
    }
    
    func startJumpBoardMovement(timeInterval: TimeInterval, multiplyer: Double, x: CGFloat, startY: CGFloat, endY: CGFloat) {
        self.frame.origin.x = x
        self.frame.origin.y = startY
        self.inMovement = true
        
        UIView.animate(withDuration: timeInterval * multiplyer, delay: 0, options: .curveLinear) {
            self.frame.origin.y = endY
        } completion: { _ in
            self.frame.origin.y = startY
            self.inMovement = false
            self.isUsed = false
        }
    }
    
}