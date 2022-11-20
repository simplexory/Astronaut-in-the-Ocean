import UIKit

private extension String {
    static let modelName = "jumpboard"
}

final class JumpBoard: GameObject {
   
    override func setup() {
        self.model.layer.contentsGravity = .resize
        self.model.layer.borderWidth = 2
        self.model.image = UIImage(named: .modelName)
    }
    
}
