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
        self.topImageView.layer.contentsGravity = .resizeAspectFill
        self.bottomImageView.layer.contentsGravity = .resizeAspectFill
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
        topImageView.layer.removeAllAnimations()
        bottomImageView.layer.removeAllAnimations()
    }
    
    func update(multiplyer: Double) {
        guard let topFrame = topImageView.layer.presentation()?.frame,
              let bottomFrame = bottomImageView.layer.presentation()?.frame else { return }
        
        let path = topImageView.frame.height
        let currentTopY = topFrame.origin.y
        let currentBottomY = bottomFrame.origin.y
        let coefficient = (1 - currentTopY / path) * multiplyer
        let newDuration: TimeInterval = .backgroundMovementTime * coefficient
        
        stop()
        topImageView.frame.origin.y = currentTopY
        bottomImageView.frame.origin.y = currentBottomY
        
        
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
