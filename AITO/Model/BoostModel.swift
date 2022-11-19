import UIKit

private extension String {
    static let modelName = "boost"
    static let fileFormat = ".png"
}

final class Boost: GameObject {
   
    override func setup() {
        self.model.layer.contentsGravity = .resize
        self.model.layer.borderWidth = 2
        self.model.image = UIImage(named: .modelName + .fileFormat)
    }
    
}
