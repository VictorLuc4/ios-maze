//
//  GameScene.swift
//  mazespritekit
//
//  Created by Victor Lucas on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playerDelegate: PlayerControllerDelegate = PlayerController()
    
    let manager = CMMotionManager()
    var goal:SKNode = SKNode()
    
    var velocity:CGVector? = CGVector()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        // set up player
        playerDelegate.setUpPlayerSprite(frame: frame, withCallback: {
            sprite in
            addChild(sprite)
        })
        
        goal = self.childNode(withName: "goal")!
        goal.physicsBody?.affectedByGravity = false
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.05
        manager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: OperationQueue.main){ data,error in
            let pit = self.manager.deviceMotion?.attitude.pitch // haut bas
            let yaw = self.manager.deviceMotion?.attitude.yaw // droite gauche
            let roll = self.manager.deviceMotion?.attitude.roll // roulade
            
            let runDirection = CGVector(dx:CGFloat(Float(roll!)) , dy: CGFloat(Float(-1 * pit!)))
            
            self.playerDelegate.run(direction: runDirection, velocity: self.velocity!)
        }
        manager.startAccelerometerUpdates(to: OperationQueue.main){ data,error in
            self.velocity = CGVector(dx: (data?.acceleration.x)! * 360, dy: (data?.acceleration.y)! * 360)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let A = contact.bodyA
        let B = contact.bodyB
        
        print("A : \(A.categoryBitMask) \n B :\(B.categoryBitMask)")
        
        if ((A.categoryBitMask == 1 && B.categoryBitMask == 3) || (A.categoryBitMask == 3 && B.categoryBitMask == 1)){
            print("End Scene")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // nothing
    }

}
