import UIKit

private extension String {
    static let modelName = "coin"
    static let fileFormat = ".png"
}

final class Coin: GameObject {
   
    override func setup() {
        self.model.layer.contentsGravity = .resize
        self.model.layer.borderWidth = 2
        self.model.image = UIImage(named: .modelName + .fileFormat)
    }
    
}
