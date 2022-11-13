import Foundation

import UIKit

private extension String {
    static let modelName = "coin"
    static let fileFormat = ".png"
}

final class Coin: UIImageView {
   
    var inMovement = false
    var isUsed = false
    
    func setup() {
        self.layer.contentsGravity = .resize
        self.layer.borderWidth = 2
        self.image = UIImage(named: .modelName + .fileFormat)
    }
    
    func take() {
        self.isHidden = true
        self.isUsed = true
    }
    
    func unTake() {
        self.isHidden = false
        self.isUsed = false
    }
    
    func start(timeInterval: TimeInterval, multiplyer: Double, x: CGFloat, startY: CGFloat, endY: CGFloat) {
        self.frame.origin.x = x
        self.frame.origin.y = startY
        self.inMovement = true
        
        UIView.animate(withDuration: timeInterval * multiplyer, delay: 0, options: .curveLinear) {
            self.frame.origin.y = endY
        } completion: { _ in
            self.frame.origin.y = startY
            self.inMovement = false
            self.unTake()
        }
    }
    
}
