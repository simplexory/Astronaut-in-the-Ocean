import UIKit

private extension TimeInterval {
    static let animationDuration = 0.5
}

private extension String {
    static let modelName = "player_"
    static let waterName = "water_collision_"
}

private extension Int {
    static let startImageNumber = 1
    static let endImageNumber = 8
}

private extension CGFloat {
    static let waterCollisionSizeMultiplyer: CGFloat = 2.7
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
            model.stopAnimating()
            waterCollision.stopAnimating()
            model.isHidden = true
            waterCollision.isHidden = true
        case false:
            model.startAnimating()
            waterCollision.startAnimating()
            model.isHidden = false
            waterCollision.isHidden = false
        }
    }
    
    func jump() {
        let startSize = model.frame.size
        isJumpingNow = true
        model.stopAnimating()
        waterCollision.stopAnimating()
        
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
        guard let layer = model.layer.presentation()?.frame else { return true }
        guard let superview = model.superview?.frame else { return true }
        let currentXPos = layer.origin.x
        
        if currentXPos <= 0 || currentXPos >= superview.width - model.frame.width {
            return false
        }
        
        return true
    }
    
    func setup(viewWidth: CGFloat, viewHeight: CGFloat) {
        let playerSize = viewWidth / .contentDivider
        let collisionSize = viewWidth / (.contentDivider / .waterCollisionSizeMultiplyer )
        let startPlayerPoint = CGPoint(
            x: viewWidth / 2 - playerSize / 2,
            y: viewHeight - (playerSize + viewHeight / .playerPaddingMultiplyer)
        )
        let startCollisionWaterPoint = CGPoint(
            x: viewWidth / 2 - collisionSize / 2,
            y: startPlayerPoint.y
        )
        let playerFrameSize = CGSize(width: playerSize, height: playerSize)
        let collisionWaterFrameSize = CGSize(width: collisionSize, height: collisionSize)
        
        
        startPlayerPos = startPlayerPoint
        model.frame = CGRect(origin: startPlayerPoint, size: playerFrameSize)
        model.layer.contentsGravity = .resize
        model.layer.borderWidth = 2
        model.animationImages = setImageAnimationSet(imageName: .modelName)
        model.animationDuration = .animationDuration
        model.image = UIImage(named: .modelName + String(Int.startImageNumber))
        
        startWaterCollisionPos = startCollisionWaterPoint
        waterCollision.frame = CGRect(origin: startCollisionWaterPoint, size: collisionWaterFrameSize)
        waterCollision.layer.contentsGravity = .resize
        waterCollision.layer.borderWidth = 2
        waterCollision.animationImages = setImageAnimationSet(imageName: .waterName)
        waterCollision.animationDuration = .animationDuration
        waterCollision.layer.opacity = .waterCollisionOpacity
    }
    
    private func setImageAnimationSet(imageName: String) -> [UIImage] {
        var imgListArray: [UIImage] = []
        
        for countValue in Int.startImageNumber...Int.endImageNumber {
            let strImageName: String = imageName + String(countValue)
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
            model.frame.origin = playerPos
            waterCollision.frame.origin = waterPos
        }
    }
    
}
