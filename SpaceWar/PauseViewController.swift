//
//  PauseViewController.swift
//  SpaceWar
//
//  Created by Александр Печинкин on 08.04.2024.
//

import UIKit

protocol PauseVCDelegate {
    func pauseViewControllerPlayButton(_ viewController: PauseViewController)
}

class PauseViewController: UIViewController {
    
    var delegate: PauseVCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func playButtonPress(_ sender: UIButton) {
        delegate.pauseViewControllerPlayButton(self)
    }
    
    @IBAction func storeButtonPress(_ sender: UIButton) {
    }
    
    @IBAction func menuButtonPress(_ sender: UIButton) {
    }
    
}
