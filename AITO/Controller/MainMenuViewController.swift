import UIKit

private extension CGFloat {
    static let startButtonConstraint: CGFloat = -120
    static let buttonConstraint: CGFloat = 50
    static let roundCornerImageRadius: CGFloat = 15
    static let buttonFontSize: CGFloat = 50
    static let labelFontSize: CGFloat = 25
    static let playerNameFontSize: CGFloat = 40 // change UILabel extension for input method too
}

private extension String {
    static let buttonText: String = "NEW GAME"
    static let scoreText: String = "HIGHT SCORE"
}

private extension Float {
    static let viewOpacity: Float = 0.9
}

private extension TimeInterval {
    static let buttonAnimationDuration: TimeInterval = 1.2
}

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var mainMenuImageView: UIImageView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerInfoView: UIView!
    
    private let fakeLabel = UILabel()
    private var isAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBottomConstraint.constant = .startButtonConstraint
        registerForKeyboardNotifications()
        addTapGesture()
        setupUI()
        self.view.addSubview(fakeLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let playerName = StorageManager.shared.loadName()
        
        playerNameTextField.text = playerName
        guard isAnimated else { return animateButton() }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setScore()
    }
    
    private func setupUI() {
        startGameButton.setCyberpnukFont(text: .buttonText, size: .buttonFontSize)
        playerNameTextField.setCyberthroneFont(size: .playerNameFontSize)
        mainMenuImageView.roundCorners(radius: .roundCornerImageRadius)
        mainMenuImageView.addBlackGradient()
        playerNameTextField.addTarget(fakeLabel, action: #selector(UILabel.input(textField:)), for: .editingChanged)
        playerNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Player",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        fakeLabel.frame.size = CGSize(width: self.view.frame.width, height: .playerNameFontSize * 2)
        fakeLabel.textColor = .white
        fakeLabel.textAlignment =  .center
        fakeLabel.isHidden = true
    }
    
    private func setScore() {
        var score = ""
        
        if let matches = StorageManager.shared.matches {
            for match in matches.prefix(3) {
                score += "\(match.name) \(match.score) : \(match.time.asMatchTime())\n"
            }
        } else {
            score = "NO DATA"
        }
        
        scoreLabel.setCyberverseFont(text: "\(String.scoreText)\n\(score)", size: .labelFontSize)
    }
    
    private func animateButton() {
        buttonBottomConstraint.constant = .buttonConstraint
        startGameButton.layer.opacity = 0
        playerInfoView.layer.opacity = 0
        UIView.animate(withDuration: .buttonAnimationDuration, delay: 0, options: .curveEaseOut) {
            self.startGameButton.layer.opacity = .viewOpacity
            self.playerInfoView.layer.opacity = .viewOpacity
            self.view.layoutIfNeeded()
        }
        isAnimated = true
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardChanged(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardChanged(_ notification: NSNotification) {
            guard let userInfo = notification.userInfo,
                  let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
                  let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            
            if notification.name == UIResponder.keyboardWillHideNotification {
                fakeLabel.isHidden = true
                playerNameTextField.isHidden = false
                fakeLabel.text = .none
            } else {
                fakeLabel.setCyberverseFont(text: "Type nickname", size: .labelFontSize)
                fakeLabel.isHidden = false
                playerNameTextField.isHidden = true
                fakeLabel.frame.origin = CGPoint(x: 0, y: self.view.frame.height - frame.height)
                fakeLabel.frame.origin.y -= 100
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addTapGesture() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapDetected(_:)))
        let scoreRecognizer = UITapGestureRecognizer(target: self, action: #selector(scoreTapDetected(_:)))
        
        self.view.addGestureRecognizer(recognizer)
        self.scoreLabel.addGestureRecognizer(scoreRecognizer)
    }
    
    @objc private func scoreTapDetected(_ recognizer: UITapGestureRecognizer) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailScoreViewController") as? DetailScoreViewController else { return }
        show(controller, sender: nil)
    }
    
    @objc private func tapDetected(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func startGamePressed(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        
        if let playerName = playerNameTextField.text {
            StorageManager.shared.saveName(playerName)
        }
    
        navigationController?.pushViewController(controller, animated: false)
    }
}

extension MainMenuViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
