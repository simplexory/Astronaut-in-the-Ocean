import UIKit

private extension TimeInterval {
    static let animationDuration = 0.5
}

private extension String {
    static let modelName = "astronaut_"
    static let waterName = "water_"
}

private extension Int {
    static let startImageNumber = 1
    static let endImageNumber = 8
}

private extension CGFloat {
    static let waterCollisionSizeMultiplyer: CGFloat = 1.5
}

private extension Float {
    static let waterCollisionOpacity: Float = 0.2
}

final class Player {
    var model = UIImageView()
    var waterCollision = UIImageView()
    var isJumpingNow = false
    private var startPlayerPos: CGPoint?
    private var startWaterCollisionPos: CGPoint?
    private var imgAnimationSet: [UIImage] = []
    
    func hideModel(_ status: Bool) {
        switch status {
        case true:
            self.model.stopAnimating()
            self.waterCollision.stopAnimating()
            self.model.isHidden = true
            self.waterCollision.isHidden = true
        case false:
            self.model.startAnimating()
            self.waterCollision.startAnimating()
            self.model.isHidden = false
            self.waterCollision.isHidden = false
        }
    }
    
    func jump() {
        let startSize = self.model.frame.size
        self.isJumpingNow = true
        self.model.stopAnimating()
        self.waterCollision.stopAnimating()
        
        UIView.animateKeyframes(withDuration: .defaultJumpDuration, delay: 0, options: .autoreverse) {
            let newSize = self.model.frame.size.width * Double.sizeWhileJumping
            
            self.model.frame.size = CGSize(width: newSize, height: newSize)
        } completion: { _ in
            self.model.frame.size = startSize
            self.isJumpingNow = false
            self.model.startAnimating()
            self.waterCollision.startAnimating()
        }
    }
    
    func detectPlayerMove(direction: Move) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            let movementLenght = self.model.frame.width / .playerMovementDivider
            
            switch direction {
            case .left:
                self.model.frame.origin.x -= movementLenght
                self.waterCollision.frame.origin.x -= movementLenght
            case .right:
                self.model.frame.origin.x += movementLenght
                self.waterCollision.frame.origin.x += movementLenght
            }
            
        } completion: { isCancelled in
            guard !isCancelled else { return }
            if let playerLayer = self.model.layer.presentation(),
               let waterLayer = self.waterCollision.layer.presentation() {
                self.model.frame.origin.x = playerLayer.frame.origin.x
                self.waterCollision.frame.origin.x = waterLayer.frame.origin.x
            }
        }
    }
    
    func inCorrectPosition() -> Bool {
        guard let layer = self.model.layer.presentation()?.frame else { return true }
        guard let superview = self.model.superview?.frame else { return true }
        let currentXPos = layer.origin.x
        
        if currentXPos <= 0 || currentXPos >= superview.width - self.model.frame.width {
            return false
        }
        
        return true
    }
    
    func setup(viewWidth: CGFloat, viewHeight: CGFloat) {
        let playerSize = viewWidth / .contentDivider
        let collisionSize = viewWidth / (.contentDivider / .waterCollisionSizeMultiplyer )
        let startPlayerPoint = CGPoint(
            x: viewWidth / 2 - playerSize / 2,
            y: viewHeight - playerSize * .paddingBottomPlayerMultiplyer
        )
        let startCollisionWaterPoint = CGPoint(
            x: viewWidth / 2 - collisionSize / 2,
            y: startPlayerPoint.y + playerSize / 2
        )
        let playerFrameSize = CGSize(width: playerSize, height: playerSize)
        let collisionWaterFrameSize = CGSize(width: collisionSize, height: collisionSize)
        
        
        self.startPlayerPos = startPlayerPoint
        self.model.frame = CGRect(origin: startPlayerPoint, size: playerFrameSize)
        self.model.layer.contentsGravity = .resize
        self.model.layer.borderWidth = 2
        self.model.animationImages = setImageAnimationSet(imageName: .modelName)
        self.model.animationDuration = .animationDuration
        self.model.image = UIImage(named: .modelName + String(Int.startImageNumber) + .fileFormat)
        
        self.startWaterCollisionPos = startCollisionWaterPoint
        self.waterCollision.frame = CGRect(origin: startCollisionWaterPoint, size: collisionWaterFrameSize)
        self.waterCollision.layer.contentsGravity = .resize
        self.waterCollision.layer.borderWidth = 2
        self.waterCollision.animationImages = setImageAnimationSet(imageName: .waterName)
        self.waterCollision.animationDuration = .animationDuration
        self.waterCollision.layer.opacity = .waterCollisionOpacity
    }
    
    private func setImageAnimationSet(imageName: String) -> [UIImage] {
        var imgListArray: [UIImage] = []
        
        for countValue in Int.startImageNumber...Int.endImageNumber {
            let strImageName: String = imageName + String(countValue) + .fileFormat
            let image = UIImage(named: strImageName)
            
            if let image = image {
                imgListArray.append(image)
            }
        }
        
        return imgListArray
    }
    
    func setStartPosition() {
        if let playerPos = startPlayerPos,
           let waterPos = startWaterCollisionPos {
            self.model.frame.origin = playerPos
            self.waterCollision.frame.origin = waterPos
        }
    }
    
}
