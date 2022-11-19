import UIKit

private extension TimeInterval {
    static let animationDuration = 0.5
}

private extension String {
    static let modelName = "astronaut_"
}

private extension Int {
    static let startImageNumber = 1
    static let endImageNumber = 3
}

final class Player: UIImageView {
    
    private var imgAnimationSet: [UIImage] = []
    private var staticModel = UIImage()
    private var isAnimated: (state: Bool, direction: Move?) = (false, nil)
    var isJumpingNow = false
    var startPos: CGPoint?
    
    func hideModel(_ status: Bool) {
        switch status {
        case true:
            self.stopAnimating()
            self.isHidden = true
        case false:
            self.startAnimating()
            self.isHidden = false
        }
    }
    
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
                self.frame.origin.x -= self.frame.width / .playerMovementDivider
            case .right:
                self.frame.origin.x += self.frame.width / .playerMovementDivider
            }
            
        } completion: { isCancelled in
            guard !isCancelled else { return }
            if let layer = self.layer.presentation() {
                self.frame.origin.x = layer.frame.origin.x
            }
        }
    }
    
    func inCorrectPosition() -> Bool {
        guard let layer = self.layer.presentation()?.frame else { return true }
        guard let superview = self.superview?.frame else { return true }
        
        let currentXPos = layer.origin.x
        
        if currentXPos <= 0 || currentXPos >= superview.width - self.frame.width {
            return false
        }
        
        return true
    }
    
    func setup(startPos: CGPoint, size: CGFloat) {
        let cgSize = CGSize(width: size, height: size)
        
        self.startPos = startPos
        self.frame = CGRect(origin: startPos, size: cgSize)
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
    
    func setStartPosition() {
        if let startPos = startPos {
            self.frame.origin = startPos
        }
    }
    
}
