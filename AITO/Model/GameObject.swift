import Foundation
import UIKit

class GameObject {
    var model = UIImageView()
    var isPresented = false
    var isUsed = false
    var minY: CGFloat
    var maxY: CGFloat
    var maxX: CGFloat
    
    var frame: CGRect? {
        get {
            guard let presentation = self.model.layer.presentation() else { return nil }
            return presentation.frame
        }
    }
    
    init(size: CGFloat, maxY: CGFloat, maxX: CGFloat) {
        self.minY = -size
        self.maxY = maxY
        self.maxX = maxX - size

        self.model.frame.size = CGSize(width: size, height: size)
        self.model.frame.origin = CGPoint(x: 0, y: minY)
        
        setup()
    }
    
    func setup() {}
    
    func setDefault() {
        self.isPresented = false
        self.isUsed = false
        self.model.isHidden = false
        self.model.layer.removeAllAnimations()
        self.model.frame.origin.y = self.minY
    }
    
    func update(multiply: Double) {
        guard let frame = self.frame else { return }

        let path = -minY + maxY
        let currentY = frame.origin.y
        let coefficient = (1 - currentY / path) * multiply
        let newDurationTime: TimeInterval = .movementTime * coefficient
        
        self.model.frame.origin.y = currentY
        self.model.layer.removeAllAnimations()
        
        UIView.animate(withDuration: newDurationTime, delay: 0, options: .curveLinear) {
            
            self.model.frame.origin.y = self.maxY
        } completion: { isCancelled in
            guard isCancelled else { return }
            self.setDefault()
        }

    }
    
    func start(multiply: Double) {
        let x: CGFloat = .random(in: 0...self.maxX)
        
        self.model.frame.origin.x = x
        self.model.frame.origin.y = self.minY
        self.isPresented = true
        
        UIView.animate(withDuration: .movementTime * multiply, delay: 0, options: .curveLinear) {
            self.model.frame.origin.y = self.maxY
        } completion: { isCancelled in
            guard isCancelled else { return }
            self.setDefault()
        }
    }
    
}
