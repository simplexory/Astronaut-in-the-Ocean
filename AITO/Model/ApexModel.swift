import UIKit

private extension String {
    static let modelName = "stone"
    static let fileFormat = ".png"
}

final class Apex: UIImageView {
   
    var inMovement = false
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
    
    func start(x: CGFloat, multiply: Double) {
        self.frame.origin.x = x
        self.frame.origin.y = self.startY
        self.inMovement = true
        
        UIView.animate(withDuration: .movementTime * multiply, delay: 0, options: .curveLinear) {
            self.frame.origin.y = self.endY
        } completion: { _ in
            self.inMovement = false
        }
    }
    
}
