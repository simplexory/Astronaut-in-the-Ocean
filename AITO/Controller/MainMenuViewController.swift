import UIKit

final class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var mainMenuImageView: UIImageView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var scoreTableLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mainMenuImageView.roundCorners(radius: 10)
        self.mainMenuImageView.addBlackGradient()
        self.startGameButton.dropShadow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let playerName = StorageManager.shared.loadName()
        self.playerNameTextField.text = playerName
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
