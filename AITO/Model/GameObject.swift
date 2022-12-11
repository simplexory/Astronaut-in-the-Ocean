import Foundation
import UIKit

class GameObject {
    var model = UIImageView()
    var minY: CGFloat
    var maxY: CGFloat
    var maxX: CGFloat
    var isPresented = false
    var isUsed = false
    
    var frame: CGRect? {
        get {
            guard let presentation = model.layer.presentation() else { return nil }
            return presentation.frame
        }
    }
    
    init(size: CGFloat, maxY: CGFloat, maxX: CGFloat, divider: CGFloat) {
        minY = -(maxX / divider)
        self.maxY = maxY
        self.maxX = maxX - size

        model.frame.size = CGSize(width: size, height: size)
        model.frame.origin = CGPoint(x: 0, y: minY)
        
        setup()
    }
    
    func setup() {
        self.model.layer.contentsGravity = .resize
    }
    
    func setDefault() {
        isPresented = false
        isUsed = false
        model.isHidden = false
        model.layer.removeAllAnimations()
        model.frame.origin.y = minY
    }
    
    func update(multiply: Double) {
        guard let frame = frame else { return }

        let path = -minY + maxY
        let currentY = frame.origin.y
        let coefficient = (1 - currentY / path) * multiply
        let newDurationTime: TimeInterval = .movementTime * coefficient
        
        model.layer.removeAllAnimations()
        model.frame.origin.y = currentY
        
        UIView.animate(withDuration: newDurationTime, delay: 0, options: .curveLinear) {
            self.model.frame.origin.y = self.maxY
        } completion: { isCancelled in
            guard isCancelled else { return }
            self.setDefault()
        }
    }
    
    func start(multiply: Double, x: CGFloat) {
        model.frame.origin.x = x
        model.frame.origin.y = minY
        isPresented = true
        
        UIView.animate(withDuration: .movementTime * multiply, delay: 0, options: .curveLinear) {
            self.model.frame.origin.y = self.maxY
        } completion: { isCancelled in
            guard isCancelled else { return }
            self.setDefault()
        }
    }
    
    func getRandomPosition() -> CGFloat {
        return .random(in: 0...maxX)
    }
    
}
