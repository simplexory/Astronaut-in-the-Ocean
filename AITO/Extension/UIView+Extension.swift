import UIKit

private extension CGFloat {
    static let defaultRadius = 7.0
}

private extension Float {
    static let shadowOpacity: Float = 0.5
}

extension UIView {
    func roundCorners(radius: CGFloat = .defaultRadius) {
        self.layer.cornerRadius = radius
    }
    
    func dropShadow(radius: CGFloat = .defaultRadius) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = .shadowOpacity
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.layer.shadowRadius = 3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: .defaultRadius).cgPath
    }
    
    func addBlackGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor(white: 0, alpha: 0).cgColor,
            UIColor.black.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        gradient.frame = self.bounds
        self.layer.addSublayer(gradient)
    }
}
