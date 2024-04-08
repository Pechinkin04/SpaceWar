//
//  GameOverViewController.swift
//  SpaceWar
//
//  Created by Александр Печинкин on 08.04.2024.
//

import UIKit

protocol gameOverVCDelegate {
    func gameOverViewControllerReplayButton(_ viewController: GameOverViewController)
}

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var delegate: gameOverVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func setScore(score: Int) {
        scoreLabel.text = "\(score)"
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        delegate.gameOverViewControllerReplayButton(self)
    }
    
    @IBAction func topScoreButton(_ sender: UIButton) {
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
    }
    
}
