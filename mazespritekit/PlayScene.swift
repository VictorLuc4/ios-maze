//
//  MenuScene.swift
//  mazespritekit
//
//  Created by Victor Lucas on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import UIKit
import SpriteKit

class PlayScene: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodesarray = nodes(at: location)
            
            for node in nodesarray {
                if node.name == "playButton" {
                    let secondScene = TimerScene(fileNamed: "TimerScene")
                    let transition = SKTransition.flipVertical(withDuration: 1.0)
                    secondScene?.scaleMode = .aspectFill
                    scene?.view?.presentScene(secondScene!, transition: transition)
                }
            }
        }
    }

}
