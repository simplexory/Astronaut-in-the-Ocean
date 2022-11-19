import UIKit

extension UIButton {
    func setCyberpnukFont(text: String, size: CGFloat) {
        if let font = UIFont(name: "Cyberpnuk2", size: size) {
            let attributes = [NSAttributedString.Key.font: font]
            let result = NSAttributedString(string: text, attributes: attributes)
            
            self.setAttributedTitle(result, for: .normal)
        }
    }
}
