//
//  TimerScene.swift
//  mazespritekit
//
//  Created by Victor Lucas on 16/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import UIKit
import SpriteKit

class TimerScene: SKScene {
    
    
    var counter = 0
    var counterTime = Timer()
    var counterStartValue = 6
    
    lazy var countDownLabel : SKLabelNode = {
        var label = SKLabelNode()
        label.text = "\(counter)"
        label.fontSize = 30.0
        return label
    }()
    
    override func didMove(to view: SKView) {
        countDownLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        addChild(countDownLabel)
        
        counter = counterStartValue
        startCounter()
        
    }

    func startCounter() {
        counterTime = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                           selector: #selector(decrementCounter), userInfo: nil, repeats: true)
    }
    
    @objc func decrementCounter() {
        counter -= 1
        countDownLabel.text = "\(counter)"
        if counter == 0 {
            let secondScene = GameScene(fileNamed: "GameScene")
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            secondScene?.scaleMode = .aspectFill
            scene?.view?.presentScene(secondScene!, transition: transition)
        }
    }
}
