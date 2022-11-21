import UIKit

private extension String {
    static let modelName = "water"
}

final class Background {
    let topImageView = UIImageView()
    let bottomImageView = UIImageView()
    
    func setup(screenWidth: CGFloat, screenHeight: CGFloat) {
        let topOrigin = CGPoint(x: 0, y: -screenHeight)
        let bottomOrigin = CGPoint(x: 0, y: 0)
        let size = CGSize(width: screenWidth, height: screenHeight)
        let image = UIImage(named: .modelName)
        
        (self.topImageView.image, self.bottomImageView.image) = (image, image)
        self.topImageView.frame = CGRect(origin: topOrigin, size: size)
        self.bottomImageView.frame = CGRect(origin: bottomOrigin, size: size)
        self.topImageView.layer.contentsGravity = .resize
        self.bottomImageView.layer.contentsGravity = .resize
    }
    
    private func animationCompletion(multiplyer: Double) {
        self.topImageView.frame.origin.y = 0
        self.bottomImageView.frame.origin.y = -self.bottomImageView.frame.height
        self.start(multiplyer: multiplyer)
    }
    
    private func setAnimationPosition() {
        self.topImageView.frame.origin.y = self.topImageView.frame.height
        self.bottomImageView.frame.origin.y = 0
    }
    
    func start(multiplyer: Double) {
        UIView.animate(withDuration: .backgroundMovementTime * multiplyer, delay: 0, options: .curveLinear) {
            self.setAnimationPosition()
        } completion: { isCancelled in
            guard isCancelled else { return }
            self.animationCompletion(multiplyer: multiplyer)
        }
    }
    
    func stop() {
        if let topFrame = topImageView.layer.presentation()?.frame,
           let bottomFrame = bottomImageView.layer.presentation()?.frame {
            topImageView.frame.origin.y = topFrame.origin.y
            bottomImageView.frame.origin.y = bottomFrame.origin.y
        }
        topImageView.layer.removeAllAnimations()
        bottomImageView.layer.removeAllAnimations()
    }
    
    func update(multiplyer: Double) {
        guard let frame = topImageView.layer.presentation()?.frame else { return }
        let path = topImageView.frame.height
        let currentY = frame.origin.y
        let coefficient = (1 - currentY / path) * multiplyer
        let newDuration: TimeInterval = .backgroundMovementTime * coefficient
        
        stop()
        
        UIView.animate(withDuration: newDuration, delay: 0, options: .curveLinear) {
            self.setAnimationPosition()
        } completion: { isCancelled in
            guard isCancelled else { return }
            self.animationCompletion(multiplyer: multiplyer)
        }

    }
    
    func setDefault() {
        stop()
        topImageView.frame.origin.y = 0
        bottomImageView.frame.origin.y = -bottomImageView.frame.height
    }
}
