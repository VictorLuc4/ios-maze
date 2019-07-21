//
//  ModeScene.swift
//  mazespritekit
//
//  Created by Victor Lucas on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import UIKit
import SpriteKit

class ModeScene: SKScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodesarray = nodes(at: location)
            
            for node in nodesarray {
                if node.name == "singleButton" {
                    let secondScene = PlayScene(fileNamed: "PlayScene")
                    let transition = SKTransition.flipVertical(withDuration: 1.0)
                    secondScene?.scaleMode = .aspectFill
                    scene?.view?.presentScene(secondScene!, transition: transition)
                }
            }
        }
        
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodesarray = nodes(at: location)
            
            for node in nodesarray {
                if node.name == "multiButton" {
                    let secondScene = PlayScene(fileNamed: "PlayScene")
                    let transition = SKTransition.flipVertical(withDuration: 1.0)
                    secondScene?.scaleMode = .aspectFill
                    scene?.view?.presentScene(secondScene!, transition: transition)
                }
            }
        }
    }
}
