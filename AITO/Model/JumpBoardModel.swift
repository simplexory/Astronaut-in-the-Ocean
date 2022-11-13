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
    var startY = CGFloat()
    var endY = CGFloat()
    
    func setup(origin: CGPoint, size: CGSize, endY: CGFloat) {
        self.layer.contentsGravity = .resize
        self.layer.borderWidth = 2
        self.image = UIImage(named: .modelName + .fileFormat)
        self.frame = CGRect(origin: origin, size: size)
        self.startY = self.frame.origin.y
        self.endY = endY
    }
    
    func start(x: CGFloat) {
        self.frame.origin.x = x
        self.frame.origin.y = self.startY
        self.inMovement = true
        
        UIView.animate(withDuration: .movementTime * .speedMultiplyer, delay: 0, options: .curveLinear) {
            self.frame.origin.y = self.endY
        } completion: { _ in
            self.inMovement = false
            self.isUsed = false
        }
    }
    
}
