import UIKit

private extension String {
    static let modelName = "stone"
}

final class Apex: GameObject {
    
    override func setup() {
        self.model.image = UIImage(named: .modelName)
    }
    
}
