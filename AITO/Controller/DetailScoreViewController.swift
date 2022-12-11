//
//  DetailScoreViewController.swift
//  AITO
//
//  Created by Юра Ганкович on 11.12.22.
//

import UIKit

private extension CGFloat {
    static let rowHeight: CGFloat = 55
}

class DetailScoreViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scoreTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentDidChanged(_ sender: UISegmentedControl) {
        scoreTableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension DetailScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let matches = StorageManager.shared.matches else { return 0 }
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let matches = StorageManager.shared.matches,
              let cell = tableView.dequeueReusableCell(withIdentifier: MatchViewCell.identifier, for: indexPath) as? MatchViewCell else { return UITableViewCell() }
        
        var sortedMatches = [PlayerMatch]()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            sortedMatches = matches.sorted { $0.score > $1.score }
        case 1:
            sortedMatches = matches.sorted { $0.time > $1.time }
        default:
            return UITableViewCell()
        }
        
        cell.configureCell(match: sortedMatches[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
