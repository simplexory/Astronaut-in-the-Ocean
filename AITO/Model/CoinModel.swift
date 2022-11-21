import UIKit

private extension String {
    static let modelName = "coin"
}

final class Coin: GameObject {
   
    override func setup() {
        self.model.layer.contentsGravity = .resize
        self.model.image = UIImage(named: .modelName)
    }
    
}
