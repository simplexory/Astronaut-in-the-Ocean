import UIKit

extension UILabel {
    func setCyberverseFont(text: String, size: CGFloat) {
        if let font = UIFont(name: "Cyberverse", size: size) {
            let attributes = [NSAttributedString.Key.font: font]
            let result = NSAttributedString(string: text, attributes: attributes)
            
            self.attributedText = result
        }
    }
    
    @objc func input(textField: UITextField) {
        guard let text = textField.text else { return }
        self.setCyberverseFont(text: text, size: 35)
    }
}
