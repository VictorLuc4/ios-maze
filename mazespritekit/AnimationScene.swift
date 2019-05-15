//
//  GameScene.swift
//  mazespritekit
//
//  Created by Victor Lucas on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import SpriteKit
import GameplayKit

class AnimationScene: SKScene {
    
    let playerSpriteNode = SKSpriteNode(imageNamed: "player")
    var playerRunFrames = [SKTexture]()
    
    override func didMove(to view: SKView) {
        setUpPlayerSprite()
        run()
    }
    
    func setUpPlayerSprite() {
        playerSpriteNode.position = CGPoint(x: frame.midX, y: frame.midY)
        playerSpriteNode.size = CGSize(width: playerSpriteNode.size.width * 0.15, height: playerSpriteNode.size.height * 0.15)
        
        let textureAtlas = SKTextureAtlas(named: "Run Frames")
        
        print(textureAtlas.textureNames)
        
        for i in 1..<textureAtlas.textureNames.count {
            let textureName = "Run\(i)"
            playerRunFrames.append(textureAtlas.textureNamed(textureName))
        }
        addChild(playerSpriteNode)
    }
    
    func run() {
        let animateAction = SKAction.repeatForever(SKAction.animate(with: playerRunFrames, timePerFrame: 0.1))
        playerSpriteNode.run(animateAction, withKey: "run")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerSpriteNode.xScale = playerSpriteNode.xScale * -1
    }
    
}
