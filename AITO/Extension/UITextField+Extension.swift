import UIKit

extension UITextField {
    func setCyberthroneFont(size: CGFloat) {
        if let font = UIFont(name: "Cyberverse", size: size) {
            self.font = font
        }
    }
}
