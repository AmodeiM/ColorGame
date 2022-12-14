//
//  GameFunctions.swift
//  ColorGame
//
//  Created by Mariele Amodei on 11/30/22.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    //every second take a second away from the timeRemaining
    func launchGameTimer(){
        let timeAction = SKAction.repeatForever(SKAction.sequence([SKAction.run ({
            self.remainingTime -= 1
        }),SKAction.wait(forDuration: 1)]))
        
        timeLabel?.run(timeAction)
                                                
    }
    
    func moveVertically (up:Bool) {
        if up {
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }else {
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    func moveToNextTrack() {
        player?.removeAllActions()
        movingToTrack = true
        
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {return}
        
        if let player = self.player {
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y: player.position.y), duration: 0.2)
            
            let up = directionArray[currentTrack + 1]
            
            player.run(moveAction, completion: {
                self.movingToTrack = false
                
                if self.currentTrack != 8{
                    self.player?.physicsBody?.velocity = up ? CGVector(dx: 0, dy: self.velocityArray[self.currentTrack]) :
                    CGVector(dx: 0, dy: -self.velocityArray[self.currentTrack])
                }else{
                    self.player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            })
            currentTrack += 1
            
            self.run(moveSound)
        }
    }
    
    // called every 2 seconds
    func spawnEnemies() {
        
        var randomTrackNumber = 0
        let createPowerUp = GKRandomSource.sharedRandom().nextBool()
        
        if createPowerUp {
            randomTrackNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 6) + 1
            if let powerUpObject = self.createPowerUp(forTrack: randomTrackNumber){
                self.addChild(powerUpObject)
            }
        }
        
        for i in 1...7 {
            
            if randomTrackNumber != i {
                let randomEnemyType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
                if let newEnemy = createEnemy(type: randomEnemyType, forTrack: i){
                    self.addChild(newEnemy)
                }
            }
            
        }
        //going through node tree with name ENEMY
        //removes node if node is off of the screen
        self.enumerateChildNodes(withName: "ENEMY") { (node:SKNode, nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    func movePlayerToStart() {
        if let player = self.player{
            player.removeFromParent()
            self.player = nil
            self.createPlayer()
            self.currentTrack = 0
        }
    }
    
    func nextLevel(playerPhysicsBody: SKPhysicsBody){
        currentScore += 1
        self.run(SKAction.playSoundFileNamed("levelUp", waitForCompletion: true))
        let emitter = SKEmitterNode(fileNamed: "fireworks.sks")
        playerPhysicsBody.node?.addChild(emitter!)
        //remove emitter node
        self.run(SKAction.wait(forDuration: 0.5)){
            emitter?.removeFromParent()
            self.movePlayerToStart()
        }
        
    }
    
    func gameOver(){
        GameHandler.sharedInstance.saveGameStats()
        
        self.run(SKAction.playSoundFileNamed("levelCompleted.wav", waitForCompletion: true))
        
        let transition = SKTransition.fade(withDuration: 1)
        if let gameOverScene = SKScene(fileNamed: "GameOverScene"){
            gameOverScene.scaleMode = .aspectFit
            self.view?.presentScene(gameOverScene, transition: transition)
        }
        
    }
    
}
