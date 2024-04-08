//
//  GameViewController.swift
//  SpaceWar
//
//  Created by Александр Печинкин on 07.04.2024.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var gameScene: GameScene!
    var pauseViewController: PauseViewController!
    var gameOverViewController: GameOverViewController!
    var gameOverTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseViewController = (storyboard?.instantiateViewController(withIdentifier: "PauseViewController") as! PauseViewController)
        pauseViewController.delegate = self
        
        gameOverViewController = (storyboard?.instantiateViewController(withIdentifier: "gameOverViewController") as! GameOverViewController)
        gameOverViewController.delegate = self
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                gameScene = scene as? GameScene
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            startGameOverTimer()

        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func showPauseScreen(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        
        viewController.view.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            viewController.view.alpha = 1
        }
    }
    
    func hidePauseScreen(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
        
        viewController.view.alpha = 1
        
        UIView.animate(withDuration: 0.25) {
            viewController.view.alpha = 0
        } completion: { completed in
            viewController.view.removeFromSuperview()
        }

    }
    
    func startGameOverTimer() {
        gameOverTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            // Проверка условия проигрыша
            if self.gameScene.gameOver == true {
                gameOver()
            }
        }
    }


    
    func gameOver() {
        showPauseScreen(gameOverViewController)
        gameOverViewController.setScore(score: gameScene.score)
        gameOverTimer?.invalidate()
        gameScene.musicPlayer.stop()
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        gameScene.pauseTheGame()
        showPauseScreen(pauseViewController)
        //present(pauseViewController, animated: true, completion: nil)
    }
    
}

extension GameViewController: PauseVCDelegate {
    func pauseViewControllerSoundButton(_ viewController: PauseViewController) {
        gameScene.soundOn = !gameScene.soundOn
        
        let image = gameScene.soundOn ? UIImage(named: "on") : UIImage(named: "off")
        viewController.soundButton.setImage(image, for: .normal)
    }
    
    func pauseViewControllerMusicButton(_ viewController: PauseViewController) {
        gameScene.musicOn = !gameScene.musicOn
        gameScene.musicOnOrOff()
        
        let image = gameScene.musicOn ? UIImage(named: "on") : UIImage(named: "off")
        viewController.musicButton.setImage(image, for: .normal)
    }
    
    func pauseViewControllerPlayButton(_ viewController: PauseViewController) {
        hidePauseScreen(viewController: pauseViewController)
        gameScene.unpauseTheGame()
    }
    
}

extension GameViewController: gameOverVCDelegate {
    func gameOverViewControllerReplayButton(_ viewController: GameOverViewController) {
        hidePauseScreen(viewController: gameOverViewController)
        gameScene.resetTheGame()
        startGameOverTimer()
        gameScene.musicPlayer.play()
    }
    
    
}
