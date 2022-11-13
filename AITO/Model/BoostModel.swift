import UIKit

private extension String {
    static let modelName = "boost"
    static let fileFormat = ".png"
}

final class Boost: UIImageView {
   
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
    
    func take() {
        self.isHidden = true
        self.isUsed = true
    }
    
    func untake() {
        self.isHidden = false
        self.isUsed = false
    }
    
    func start(x: CGFloat, multiply: Double) {
        self.frame.origin.x = x
        self.frame.origin.y = self.startY
        self.inMovement = true
        
        UIView.animate(withDuration: .movementTime * multiply, delay: 0, options: .curveLinear) {
            self.frame.origin.y = self.endY
        } completion: { _ in
            self.inMovement = false
            self.untake()
        }
    }
    
}
