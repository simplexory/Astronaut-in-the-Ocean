import UIKit

private extension CGFloat {
    static let startButtonConstraint: CGFloat = -120
    static let buttonConstraint: CGFloat = 50
    static let roundCornerImageRadius: CGFloat = 15
    static let buttonFontSize: CGFloat = 50
    static let labelFontSize: CGFloat = 25
    static let playerNameFontSize: CGFloat = 40
}

private extension String {
    static let buttonText: String = "NEW GAME"
    static let scoreText: String = "LAST SCORE"
}

private extension Float {
    static let viewOpacity: Float = 0.9
}

private extension TimeInterval {
    static let buttonAnimationDuration: TimeInterval = 1.2
}

final class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var mainMenuImageView: UIImageView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var scoreTableLabel: UILabel!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerInfoView: UIView!
    
    private var isAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBottomConstraint.constant = .startButtonConstraint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startGameButton.setCyberpnukFont(text: .buttonText, size: .buttonFontSize)
        self.playerNameTextField.setCyberthroneFont(size: .playerNameFontSize)
        self.mainMenuImageView.roundCorners(radius: .roundCornerImageRadius)
        self.mainMenuImageView.addBlackGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let playerName = StorageManager.shared.loadName()
        
        self.playerNameTextField.text = playerName
        guard isAnimated else { return animateButton() }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var score = "NO DATA"
        if let lastScore = StorageManager.shared.loadLastScore() {
            score = String(lastScore)
        }
        
        self.scoreTableLabel.setCyberverseFont(text: "\(String.scoreText)\n\(score)", size: .labelFontSize)
    }
    
    private func animateButton() {
        self.buttonBottomConstraint.constant = .buttonConstraint
        self.startGameButton.layer.opacity = 0
        self.playerInfoView.layer.opacity = 0
        UIView.animate(withDuration: .buttonAnimationDuration, delay: 0, options: .curveEaseOut) {
            self.startGameButton.layer.opacity = .viewOpacity
            self.playerInfoView.layer.opacity = .viewOpacity
            self.view.layoutIfNeeded()
        }
        self.isAnimated = true
    }
    
    @IBAction func startGamePressed(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        
        if let playerName = self.playerNameTextField.text {
            StorageManager.shared.saveName(playerName)
        }
    
        self.navigationController?.pushViewController(controller, animated: false)
    }
}
