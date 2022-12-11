//
//  MatchViewCell.swift
//  AITO
//
//  Created by Юра Ганкович on 11.12.22.
//

import UIKit

private extension CGFloat {
    static let fontSize: CGFloat = 20
}

class MatchViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    static let identifier = "MatchViewCell"
    
    func configureCell(match: PlayerMatch) {
        self.usernameLabel.setCyberverseFont(text: match.name, size: .fontSize)
        self.scoreLabel.setCyberverseFont(text: String(match.score), size: .fontSize)
        self.timeLabel.setCyberverseFont(text: match.time.asMatchTime(), size: .fontSize)
    }

}
