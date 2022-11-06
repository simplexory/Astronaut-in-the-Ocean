//
//  MainMenuViewController.swift
//  AITO
//
//  Created by Юра Ганкович on 6.11.22.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    @IBAction func startGamePressed(_ sender: UIButton) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(controller, animated: false)
    }
}
