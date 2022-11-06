//
//  MainMenuViewController.swift
//  AITO
//
//  Created by Юра Ганкович on 6.11.22.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var mainMenuImageView: UIImageView!
    @IBOutlet weak var startGameButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mainMenuImageView.roundCorners(radius: 10)
        self.mainMenuImageView.addBlackGradient()
        self.startGameButton.dropShadow()
    }
    
    @IBAction func startGamePressed(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(controller, animated: false)
    }
}
