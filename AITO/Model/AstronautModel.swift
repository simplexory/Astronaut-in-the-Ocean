//
//  TestAnimationModel.swift
//  AITO
//
//  Created by Юра Ганкович on 3.11.22.
//


import Foundation
import UIKit

private extension TimeInterval {
    static let animationDuration = 0.5
}

private extension Double {
    static let sizeWhileJumping = 1.5
}

private extension String {
    static let modelName = "astronaut_"
    static let fileFormat = ".png"
}

private extension Int {
    static let startImageNumber = 1
    static let endImageNumber = 3
}

final class Astronaut: UIImageView {
    
    private var imgAnimationSet: [UIImage] = []
    private var staticModel = UIImage()
    var isJumpingNow = false
    
    func jump(duration: TimeInterval) {
        let startSize = self.frame.size
        self.isJumpingNow = true
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .autoreverse) {
            self.frame.size = CGSize(
                width: self.frame.size.width * Double.sizeWhileJumping,
                height: self.frame.size.height * Double.sizeWhileJumping
            )
        } completion: { _ in
            self.frame.size = startSize
            self.isJumpingNow = false
        }
    }
    
    func detectPlayerMove(direction: Move) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            
            
            switch direction {
            case .left:
                self.frame.origin.x -= self.frame.width / 3
            case .right:
                self.frame.origin.x += self.frame.width / 3
            }
        } completion: { isCancelled in
            guard !isCancelled else { return }
            
            if let layer = self.layer.presentation() {
                self.frame.origin.x = layer.frame.origin.x
            }
        }
        
    }
    
    func configurePlayerAnimation() {
        self.layer.contentsGravity = .resize
        self.layer.borderWidth = 2
        self.animationImages = setImageAnimationSet()
        self.animationDuration = .animationDuration
        self.image = UIImage(named: .modelName + String(Int.startImageNumber) + .fileFormat)
    }
    
    private func setImageAnimationSet() -> [UIImage] {
        var imgListArray: [UIImage] = []
        
        for countValue in Int.startImageNumber...Int.endImageNumber {
            let strImageName: String = .modelName + String(countValue) + .fileFormat
            let image = UIImage(named: strImageName)
            
            if let image = image {
                imgListArray.append(image)
            }
        }
        
        return imgListArray
    }
    
}
