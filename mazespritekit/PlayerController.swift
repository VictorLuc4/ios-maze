//
//  PlayerController.swift
//  mazespritekit
//
//  Created by Antoine Masselot on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerController: PlayerControllerDelegate {
    var playerSpriteNode = SKSpriteNode(imageNamed: "player1")
    var playerRunFrames = [SKTexture]()
    var sprite: SKSpriteNode {
        return playerSpriteNode
    }
    
    func setUpPlayerSprite(frame: CGRect, position: CGPoint, withCallback cb: (SKSpriteNode) -> Void) {
        playerSpriteNode.position = position
        playerSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 60))
        playerSpriteNode.physicsBody?.isDynamic = true
        playerSpriteNode.physicsBody?.allowsRotation = false
        playerSpriteNode.physicsBody?.affectedByGravity = false
        playerSpriteNode.size = CGSize(width: playerSpriteNode.size.width * 0.15, height: playerSpriteNode.size.height * 0.15)
        
        cb(playerSpriteNode)
    }
    
    func run(direction: CGVector, velocity: CGVector) {
        playerSpriteNode.physicsBody?.velocity = velocity
        playerSpriteNode.physicsBody?.applyImpulse(direction)

        if !playerSpriteNode.hasActions() {
            let animateAction = SKAction.repeatForever(SKAction.animate(with: playerRunFrames, timePerFrame: 0.1))
            playerSpriteNode.run(animateAction, withKey: "run")
        }
        
        // Run Direction
        // If sprite is running towards the left, and force direction is -> right
        // or if sprite running towards right and force's direction is -> left
        // Flip sprite horizontally to face the right direction
        if (direction.dx > 0 && playerSpriteNode.xScale < 0) || (direction.dx < 0 && playerSpriteNode.xScale > 0) {
            playerSpriteNode.xScale = playerSpriteNode.xScale * (-1)
        }
    }
    
    required init(frame: CGRect, playerNumber: Int, callback: (SKSpriteNode) -> Void) {
        let spriteName = "player\(playerNumber)"
        playerSpriteNode = SKSpriteNode(imageNamed: spriteName)
        
        guard let position = playerPosition[playerNumber] else { return }
        
        let textureAtlas = SKTextureAtlas(named: "Run Player \(playerNumber)")
        
        for i in 1..<textureAtlas.textureNames.count {
            let textureName = "Run\(playerNumber)\(i)"
            playerRunFrames.append(textureAtlas.textureNamed(textureName))
        }
        
        self.setUpPlayerSprite(frame: frame, position: position, withCallback: callback)
    }
}

protocol PlayerControllerDelegate {
    var sprite: SKSpriteNode { get }
    func run(direction: CGVector, velocity: CGVector)
    func setUpPlayerSprite(frame: CGRect, position: CGPoint, withCallback cb: (SKSpriteNode) -> Void)
    
    init(frame: CGRect, playerNumber: Int, callback: (SKSpriteNode) -> Void)
}
