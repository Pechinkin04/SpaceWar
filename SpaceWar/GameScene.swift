//
//  GameScene.swift
//  SpaceWar
//
//  Created by Александр Печинкин on 07.04.2024.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let spaceShipCategory: UInt32 = 0x1 << 0 // 00..01
    let asteroidCategory: UInt32 = 0x1 << 1 // 00..10
    
    //1 Создаем свойства
    var spaceShip: SKSpriteNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var spaceBackground: SKSpriteNode!
    var asteroidLayer: SKNode!
    var starsLayer: SKNode!
    var gameIsPaused: Bool = false
    var spaceShipLayer: SKNode!
    var musicPlayer: AVAudioPlayer!
    
    var musicOn = true
    var soundOn = true
    var gameOver = false
    
    func musicOnOrOff() {
        if musicOn {
            musicPlayer.play()
        } else {
            musicPlayer.stop()
        }
    }
    
    func pauseTheGame() {
        gameIsPaused = true
        self.asteroidLayer.isPaused = true
        physicsWorld.speed = 0
        starsLayer.isPaused = true
        spaceShipLayer.isPaused = true
        
        musicOnOrOff()
    }
    
    func unpauseTheGame(){
        gameIsPaused = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        starsLayer.isPaused = false
        spaceShipLayer.isPaused = false
    }
    func resetTheGame() {
        gameOver = false
        asteroidLayer.removeAllChildren()
        
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        gameIsPaused = false
        self.asteroidLayer.isPaused = false
        physicsWorld.speed = 1
        starsLayer.isPaused = false
        spaceShipLayer.isPaused = false
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -0.8)
        
        scene?.size = UIScreen.main.bounds.size
        
        //size
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        spaceBackground = SKSpriteNode(imageNamed: "spaceBackground")
        spaceBackground.size = CGSize(width: width + 50, height: height + 50)
        //spaceBackground.size = self.frame.size
        addChild(spaceBackground)
        
        //stars
        //let starsPath = Bundle.main.path(forResource: "Stars", ofType: "sks")
        let starsEmitter = SKEmitterNode(fileNamed: "Stars.sks")
        starsEmitter?.zPosition = 1
        starsEmitter?.position = CGPoint(x: frame.midX, y: frame.height / 2)
        starsEmitter?.particlePositionRange.dx = frame.width
        starsEmitter?.advanceSimulationTime(10)
        
        starsLayer = SKNode()
        addChild(starsLayer)
        
        starsLayer.addChild(starsEmitter!)
        
        //2 init node
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        
        //spaceShip.position = CGPoint(x: 0, y: -300)
        spaceShip.size = CGSize(width: 60, height: 60)
        spaceShip.xScale = 1
        spaceShip.yScale = 1
        
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceBackground.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        
        spaceShip.physicsBody?.categoryBitMask = spaceShipCategory
        spaceShip.physicsBody?.collisionBitMask = asteroidCategory
        spaceShip.physicsBody?.contactTestBitMask = asteroidCategory
        
        let colorAction1 = SKAction.colorize(with: .systemYellow, colorBlendFactor: 1, duration: 2)
        let colorAction2 = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 1)
        
        let colorSequenceanimation = SKAction.sequence([colorAction1, colorAction2])
        let colorActionRepeat = SKAction.repeatForever(colorSequenceanimation)
        
        spaceShip.run(colorActionRepeat)
        
        //addChild(spaceShip)
        
        //создаем слой для космического корабля и огня
        spaceShipLayer = SKNode()
        spaceShipLayer.addChild(spaceShip)
        spaceShipLayer.zPosition = 3
        spaceShip.zPosition = 1
        spaceShipLayer.position = CGPoint(x: frame.midX, y: -frame.height / 4)
        addChild(spaceShipLayer)
        
        //создаем огонь
        let fireEmitter = SKEmitterNode(fileNamed: "Fire.sks")
        fireEmitter?.zPosition = 0
        fireEmitter?.position.y = -30
        fireEmitter?.targetNode = self
        spaceShipLayer.addChild(fireEmitter!)
        
        //generation asteroid
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 2
        addChild(asteroidLayer)
        
        let asteroidCreate = SKAction.run {
            let asteroid = self.createAsteroid()
            self.asteroidLayer.addChild(asteroid)
            asteroid.zPosition = 2
        }
        let asteroidPerSecond: Double = 5
        let asteroidCreationDelay = SKAction.wait(forDuration: 1 / asteroidPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreate, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        
        self.asteroidLayer.run(asteroidRunAction)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.position = CGPoint(x: frame.size.width / scoreLabel.frame.size.width, y: 300)
        addChild(scoreLabel)
        
        spaceBackground.zPosition = 0
        //spaceShip.zPosition = 1
        scoreLabel.zPosition = 3
        
        playMusic()
    }
    
    func playMusic() {
        if let musicPath = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            musicPlayer = try! AVAudioPlayer(contentsOf: musicPath, fileTypeHint: nil)
            musicOnOrOff()
        }
        
        musicPlayer.numberOfLoops = -1
        musicPlayer.volume = 0.7
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameIsPaused {
            if let touch = touches.first {
                //3 определяем точку прикосновения
                let touchLocation = touch.location(in: self)
                //print(touchLocation)
                
                //4 создаем действие
                let distance = distanceCalc(a: spaceShip.position, b: touchLocation)
                let speed: CGFloat = 500
                let time = timeToTravelDistance(distance: distance, speed: speed)
                let moveAction = SKAction.move(to: touchLocation, duration: time)
                moveAction.timingMode = SKActionTimingMode.easeInEaseOut
                //            print("time \(time)")
                //            print("distance \(distance)")
                spaceShipLayer.run(moveAction)
                
                let bgMoveAction = SKAction.move(to: CGPoint(x: -touchLocation.x / 40, y: -touchLocation.y / 40), duration: time)
                spaceBackground.run(bgMoveAction)
                
                //isPaused = !isPaused
                //                self.asteroidLayer.isPaused = !self.asteroidLayer.isPaused
                //                physicsWorld.speed = 0
                //
                //                pauseTheGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            spaceShipLayer.position = t.location(in: self)
        }
    }
    
    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }
    
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> TimeInterval {
        let time = distance / speed
        return TimeInterval(time)
    }
    
    func createAsteroid() -> SKSpriteNode {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.size = CGSize(width: 40, height: 40)
        
        let ramdomScale = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 6)) / 4
        asteroid.xScale = ramdomScale
        asteroid.yScale = ramdomScale
        
        let halfWidth = size.width / 2
        asteroid.position.x = CGFloat.random(in: -halfWidth ... halfWidth)
        //asteroid.position.x = CGFloat(GKRandomSource.sharedRandom().nextInt(upperBound: 6))
        asteroid.position.y = frame.size.height + asteroid.size.height
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.name = "asteroid"
        
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.collisionBitMask = spaceShipCategory | asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = spaceShipCategory
        
        let asteroidSpeedX: CGFloat = 100
        asteroid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        asteroid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * asteroidSpeedX
        
        return asteroid
    }
    
    override func update(_ currentTime: TimeInterval) {
//        let asteroid = createAsteroid()
//        addChild(asteroid)
    }
    
    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodes(withName: "asteroid") { asteroid, stop in
            let hightScreen = UIScreen.main.bounds.height
            if asteroid.position.y < -hightScreen {
                asteroid.removeFromParent()
                
                self.score = self.score + 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == asteroidCategory || contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == asteroidCategory {
            //self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
            
            pauseTheGame()
            gameOver = true
        }
        
        if soundOn {
            let hitSoundAction = SKAction.playSoundFileNamed("hitSound", waitForCompletion: true)
            run(hitSoundAction)
        }
    }
    
    
}
