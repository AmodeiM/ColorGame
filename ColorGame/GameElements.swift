//
//  GameElements.swift
//  ColorGame
//
//  Created by Mariele Amodei on 11/30/22.
//

import SpriteKit
import GameplayKit

enum Enemies:Int {
    case small
    case medium
    case large
}

extension GameScene {
    
    func createHUD(){
        pause = self.childNode(withName: "pause") as? SKSpriteNode
        timeLabel = self.childNode(withName: "time") as? SKLabelNode
        scoreLabel = self.childNode(withName: "score") as? SKLabelNode
        
        remainingTime = 60
        currentScore = 0
    }
    
    func setUpTracks(){
        for i in 0 ... 8 {
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode{
                tracksArray?.append(track)
            }
        }
    }

    func createPlayer(){
        player = SKSpriteNode(imageNamed: "player")
        
        //Physics body
        player?.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        //simulation of air friction, would slow down player
        player?.physicsBody?.linearDamping = 0
        player?.physicsBody?.categoryBitMask = playerCategory
        // with whom do i want to collide?
        player?.physicsBody?.collisionBitMask = 0 //deactivating all collisions
        //with whom do i want contact?
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory | powerUpCategory        //notified when hit enemy or target
        
        guard let playerPosition = tracksArray?.first?.position.x else {return}
        player?.position = CGPoint(x: playerPosition, y: self.size.height / 2)
        
        //render
        self.addChild(player!)
        
        let pulse = SKEmitterNode(fileNamed: "pulse")!
        player?.addChild(pulse)
        pulse.position = CGPoint(x: 0, y: 0)
    }
    
    func createTarget() {
        target = self.childNode(withName: "target") as? SKSpriteNode
        target?.physicsBody = SKPhysicsBody(circleOfRadius: target!.size.width / 2)
        target?.physicsBody?.categoryBitMask = targetCategory
        target?.physicsBody?.collisionBitMask = 0   //not affected by any collisions
    }
    
    func createEnemy(type:Enemies, forTrack track: Int) -> SKShapeNode?{
        let enemySprite = SKShapeNode()
        enemySprite.name = "ENEMY"
        switch type {
        case .small:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 70),
                                      cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
        case .medium:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 100),
                                      cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 130),
                                      cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
        }
        
        guard let enemyPosition = tracksArray?[track].position else {return nil}
        
        let up = directionArray[track]
        
        enemySprite.position.x = enemyPosition.x
        enemySprite.position.y = up ? -130 : self.size.height + 130
        
        enemySprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemySprite.path!)
        enemySprite.physicsBody?.categoryBitMask = enemyCategory
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return enemySprite
        
    }
    
    func createPowerUp(forTrack track:Int) -> SKSpriteNode?{
        let powerUpSprite = SKSpriteNode(imageNamed: "powerUp")
        powerUpSprite.name = "ENEMY"
        
        powerUpSprite.physicsBody = SKPhysicsBody(circleOfRadius: powerUpSprite.size.width / 2)
        powerUpSprite.physicsBody?.linearDamping = 0
        powerUpSprite.physicsBody?.categoryBitMask = powerUpCategory
        powerUpSprite.physicsBody?.collisionBitMask = 0
        let up = directionArray[track]
        guard let powerUpXPosition = tracksArray?[track].position.x else {return nil}
        
        powerUpSprite.position.x = powerUpXPosition
        powerUpSprite.position.y = up ? -130 : self.size.height + 130
        
        powerUpSprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return powerUpSprite
    }
}
