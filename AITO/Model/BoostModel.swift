import UIKit

private extension String {
    static let modelName = "boost"
}

final class Boost: GameObject {
   
    override func setup() {
        self.model.image = UIImage(named: .modelName)
    }
    
}
